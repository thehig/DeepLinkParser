if (typeof module != 'undefined' && module.exports) {
    WinJS = require("node-winjs");
    require("./lib/XboxJS.Navigation");
}

(function deepLinkParser(){
    "use strict";

    WinJS.Namespace.define("MyApp.Utilities.RainfallDeepLink", {
        deepLinkError: function(err){
            var msg = err;
            if(err.code){
                var message = WinJS.Resources.getString(err.code);
                if(message && message.value) msg = message.value + " (" + err.code + ")";
            }

            var title = WinJS.Resources.getString("deepLinkErrorTitle");

            if(title && title.value) {
                title = title.value;
            } else {
                title = "Error loading deep-link";
            }

            return MyApp.Utilities.showCustomPromptAsync({
                title: title,
                message: msg
            }).then(function(clickResult){
                // Even though we've handled the error, we want to continue down the error chain
                throw new Error("Deep link failed to load: " + clickResult.commandResult);
            });                            
        },

        // Check for anything that causes a redirect to home without an error
        redirectsToHome: function(protocolActivation){
            // Errors parsing the protocol activation should happen before this function
            //  -> Home
            if(!protocolActivation || !protocolActivation.options) return true;

            // No location name? (blank)
            //  -> Home
            if(!protocolActivation.locationName) return true;

            // Authority not Media-Details or Media-Playback
            //  covers: 'default', 'media-settings', 'media-help' and malformed
            //  -> Home
            if(protocolActivation.locationName !== XboxJS.Navigation.LocationName.mediaDetailsUri && 
                protocolActivation.locationName !== XboxJS.Navigation.LocationName.mediaPlaybackUri)
                return true;

            // Content ID missing
            //  -> Home
            if(!protocolActivation.options.contentId) return true;

            // Might be valid, don't go home just yet
            return false;
        },

        // Check for validity errors, can return true, false and {error&code}
        validateDataPair: function(protocolActivation){
            // Errors parsing the protocol activation should happen before this function
            //  -> Home
            if(!protocolActivation || !protocolActivation.options) return false;

            // ContentID not a positive integer
            //  -> Error
            var contentId = parseInt(protocolActivation.options.contentId);
            if(!contentId || contentId < 0) return { error: "Invalid Content Id", code: "DL002"};

            // Content Type not TvSeries, TvSeason or TvEpisode
            //  -> Error
            var contentType = protocolActivation.options.contentType;
            if(!contentType) return { error: "Missing or invalid Content Type", code: "DL003"};
            if(contentType != XboxJS.Data.ContentType.tvSeries &&
                contentType != XboxJS.Data.ContentType.tvSeason &&
                contentType != XboxJS.Data.ContentType.tvEpisode)
                return { error: "Unsupported Content Type", code: "DL001"};

            // Valid, recognised data pair
            return true;
        },

        // Process the activation, can return {processed activation}, {error&code} or undefined in edge case
        processValidPair: function(protocolActivation){
            // Any of the below indicate a basic invalidity of the pair
            //  -> Home
            if(!protocolActivation || 
                !protocolActivation.options || 
                !protocolActivation.options.contentId || 
                !protocolActivation.options.contentType) 
                return undefined;

            var contentType = protocolActivation.options.contentType;
            var contentId = protocolActivation.options.contentId;
            var navigationUri = undefined;
            var navigationOptions = undefined;

            var deepLinkError = MyApp.Utilities.RainfallDeepLink.deepLinkError;

            switch (contentType) {
                case XboxJS.Data.ContentType.tvSeries: // Retailer (1 or more IDs)
                    navigationUri = "/pages/browse/byHub/byHub.html";
                    navigationOptions = {
                        dataFunction: function() {
                            return Rainfall.Services.Retailers.getRetailer(contentId).then(function(retailers) {
                                if (!retailers || !Array.isArray(retailers) || retailers.length === 0) {
                                    var error = new Error("No retailers recieved for ID " + contentId);
                                    error.code = "DL005";
                                    throw error;
                                }

                                var retailerPromises = [];
                                retailers.forEach(function(retailer) {

                                    var promise = Rainfall.Services.Categories.getCategory(retailer.defaultCategories.join())
                                        .then(function(defaultCategories) {
                                            retailer.tiles = defaultCategories;
                                            return retailer;
                                        });
                                    retailerPromises.push(promise);
                                });

                                return WinJS.Promise.join(retailerPromises);
                            }).then(null, deepLinkError);
                        }
                    }
                    break;

                case XboxJS.Data.ContentType.tvSeason: // Category (1 or more IDs)
                    navigationUri = "/pages/browse/byHub/byHub.html";
                    navigationOptions = {
                        dataFunction: function() {
                            return Rainfall.Services.Categories.getCategory(contentId).then(function(categories) {
                                if (!categories || !Array.isArray(categories) || categories.length === 0) {
                                    var error = new Error("No categories recieved for ID " + contentId);
                                    error.code = "DL006";
                                    throw error;
                                }

                                var categoryPromises = [];
                                categories.forEach(function(category) {
                                    var promise = undefined;
                                    if (category.children && category.children.length > 0) {
                                        promise = Rainfall.Services.Categories.getCategory(category.children)
                                            .then(function(children) {
                                                category.tiles = children;
                                                return category;
                                            });
                                    } else if (category.products) {
                                        promise = Rainfall.Services.Products.getProducts(category.products)
                                            .then(function(products) {
                                                category.tiles = products;
                                                return category;
                                            });
                                    }
                                    categoryPromises.push(promise);
                                });

                                return WinJS.Promise.join(categoryPromises);
                            }).then(null, deepLinkError);
                        }
                    }
                    break;

                case XboxJS.Data.ContentType.tvEpisode: // Product (1 ID only)
                    navigationUri = "/pages/products/product/product.html";
                    navigationOptions = {
                        dataFunction: function() {
                            return Rainfall.Services.Products.getProducts(contentId).then(function(products) {
                                if (!products || !Array.isArray(products) || products.length === 0) {
                                    var error = new Error("No products recieved for ID " + contentId);
                                    error.code = "DL007";
                                    throw error;
                                }

                                return products[0];
                            }).then(null, deepLinkError);
                        }
                    }
                    break;

                default:
                    // Unsupported Content-Type
                    //  -> Error
                    return {
                        error: new Error("Unsupported deep-link content type"),
                        code: "DL001"
                    }
            }

            // Return the fully processed deep link with attached data functions
            // These data functions may raise errors through the navigation options
            //  -> Content
            return {
                contentId: contentId,
                contentType: contentType,
                navUri: "" + navigationUri, // Make new string to avoid byRef issues later
                navOptions: navigationOptions
            };
        },

        parseDeepLinkMoreBetterer: function(args){
            var protocolLaunchOptions = {};

            // Parse and store the args
            var protocolActivation = XboxJS.Navigation.parseProtocolActivation(args);
            protocolLaunchOptions.parsedActivation = protocolActivation;

            // Unable to parse protocol activation
            //  -> Error
            if(!protocolActivation) {
                protocolLaunchOptions.error = new Error("Could not parse deep link activation");
                protocolLaunchOptions.error.code = "DL004";
                return protocolLaunchOptions;
            }

            // Invalid or unrecognised authority or missing contentId
            //  -> Home
            if(MyApp.Utilities.RainfallDeepLink.redirectsToHome(protocolActivation)) 
                return protocolLaunchOptions;

            // Check to see if the contentId and contentType are valid
            // Responses are: true, false and {message, code}
            var isValidPair = MyApp.Utilities.RainfallDeepLink.validateDataPair(protocolLaunchOptions);

            // Invalid pair but no message or error code
            //  -> Home
            if(isValidPair === false) return protocolLaunchOptions;
            // Invalid pair with message and code
            //  -> Error
            if(isValidPair.error && isValidPair.code){
                protocolLaunchOptions.error = new Error(isValidPair.message);
                protocolLaunchOptions.error.code = isValidPair.code;
                return protocolLaunchOptions;
            }
            // Only remaining valid value is 'true', so if it's not that theres something wrong
            //  -> Home
            if(isValidPair !== true) return protocolLaunchOptions;

            // Process the valid pair
            var processedActivation = MyApp.Utilities.RainfallDeepLink.processValidPair(protocolLaunchOptions);
            // No result indicates something very wrong
            //  -> Home
            if(!processedActivation) return protocolLaunchOptions;
            // Return any processing errors
            //  -> Error
            if(processedActivation.error && processedActivation.code) {
                protocolLaunchOptions.error = new Error(processedActivation.message);
                protocolLaunchOptions.error.code = processedActivation.code;
                return protocolLaunchOptions;
            }

            // Attach the successful postprocess output
            //  -> Content
            protocolActivation.postProcess = processedActivation;
            return protocolActivation;
        },

        parseDeepLink: function(args){
            var protocolLaunchOptions = {};

            if(args && args.detail && args.detail.uri && args.detail.uri.rawUri){
                // Check for "empty" params eg: xbapp launch "ms-xbl-TITLEID://"
                var uri = args.detail.uri.rawUri;
                var index = uri.indexOf('://');
                var remainder = uri.substring(index + 3);
                if(remainder.length <= 1){
                    // Blank URI
                    return undefined;
                }
            }

            // Call parseProtocolActivation to determine if we are being requested to navigate to a deep link.
            // If so we should navigate to the page in our application that handles the link.
            var protocolActivation = XboxJS.Navigation.parseProtocolActivation(args);
            protocolLaunchOptions.parsedActivation = protocolActivation;

            var navigationUri = MyApp.Utilities.User.appHomePage;
            var navigationOptions = undefined;

            var deepLinkError = MyApp.Utilities.RainfallDeepLink.deepLinkError;

            // Unable to parse protocol activation
            //  -> Error -> Home
            if(!protocolActivation) {
                protocolLaunchOptions.error = new Error("Could not parse deep link activation");
                protocolLaunchOptions.error.code = "DL004";
                return protocolLaunchOptions;
            }

            // Missing authority
            //  -> Home
            if(protocolActivation.options && !protocolActivation.options.authority)
                return protocolLaunchOptions;

            // Default authority 
            //  -> Home
            if(protocolActivation.options && protocolActivation.options.authority && protocolActivation.options.authority === 'default') 
                return protocolLaunchOptions;

            // Media-Settings or Media-Help 
            //  -> Home
            if (protocolActivation.locationName === XboxJS.Navigation.LocationName.mediaHelpUri || protocolActivation.locationName === XboxJS.Navigation.LocationName.mediaSettingsUri) 
                return protocolLaunchOptions;

            // Missing Content ID, non-integer or negative-integer 
            //  -> Home
            var contentId = parseInt(protocolActivation.options.contentId);
            if(!contentId || contentId <= 0)
                return protocolLaunchOptions;

            // Missing Content-Type
            //  -> Error -> Home
            var contentType = protocolActivation.options.contentType;
            if(!contentType){
                protocolLaunchOptions.error = new Error("Required deep-link parameter not provided");
                protocolLaunchOptions.error.code = "DL002";
                return protocolLaunchOptions;
            }

            // Media-Details or Media-Playback
            //  -> Content
            if (protocolActivation.locationName === XboxJS.Navigation.LocationName.mediaDetailsUri || 
                protocolActivation.locationName === XboxJS.Navigation.LocationName.mediaPlaybackUri) {

                switch (contentType) {
                    case XboxJS.Data.ContentType.tvSeries: // Retailer (1 or more IDs)
                        navigationUri = "/pages/browse/byHub/byHub.html";
                        navigationOptions = {
                            dataFunction: function () {
                                return Rainfall.Services.Retailers.getRetailer(contentId).then(function (retailers) {
                                    if (!retailers || !Array.isArray(retailers) || retailers.length === 0) {
                                        var error = new Error("No retailers recieved for ID " + contentId);
                                        error.code = "DL005";
                                        throw error;
                                    }

                                    var retailerPromises = [];
                                    retailers.forEach(function(retailer){

                                       var promise = Rainfall.Services.Categories.getCategory(retailer.defaultCategories.join())
                                        .then(function (defaultCategories) {
                                            retailer.tiles = defaultCategories;
                                            return retailer;
                                        });
                                        retailerPromises.push(promise);
                                    });

                                    return WinJS.Promise.join(retailerPromises);
                                }).then(null, deepLinkError);
                            }
                        }
                        break;

                    case XboxJS.Data.ContentType.tvSeason: // Category (1 or more IDs)
                        navigationUri = "/pages/browse/byHub/byHub.html";
                        navigationOptions = {
                            dataFunction: function () {
                                return Rainfall.Services.Categories.getCategory(contentId).then(function (categories) {
                                    if (!categories || !Array.isArray(categories) || categories.length === 0) {
                                        var error = new Error("No categories recieved for ID " + contentId);
                                        error.code = "DL006";
                                        throw error;
                                    }

                                    var categoryPromises = [];
                                    categories.forEach(function(category){
                                        var promise = undefined;
                                        if(category.children && category.children.length > 0){
                                            promise = Rainfall.Services.Categories.getCategory(category.children)
                                                .then(function(children){
                                                    category.tiles = children;
                                                    return category;
                                                });
                                        } else if (category.products) {
                                            promise = Rainfall.Services.Products.getProducts(category.products)
                                                .then(function(products){
                                                    category.tiles = products;
                                                    return category;
                                                });
                                        }
                                        categoryPromises.push(promise);
                                    });

                                    return WinJS.Promise.join(categoryPromises);
                                }).then(null, deepLinkError);
                            }
                        }
                        break;

                    case XboxJS.Data.ContentType.tvEpisode: // Product (1 ID only)
                        navigationUri = "/pages/products/product/product.html";
                        navigationOptions = {
                            dataFunction: function(){
                                return Rainfall.Services.Products.getProducts(contentId).then(function (products) {
                                    if (!products || !Array.isArray(products) || products.length === 0) {
                                        var error = new Error("No products recieved for ID " + contentId);
                                        error.code = "DL007";
                                        throw error;
                                    }

                                    return products[0];
                                }).then(null, deepLinkError);
                            }
                        }
                        break;
                    
                    default:
                        // Unsupported Content-Type
                        //  -> Error -> Home
                        protocolLaunchOptions.error = new Error("Unsupported deep-link content type");
                        protocolLaunchOptions.error.code = "DL001";
                        break;
                }

                protocolLaunchOptions.postprocess = {
                    contentId: contentId,
                    contentType: contentType,
                    navUri: "" + navigationUri, // Make new string to avoid byRef issues later
                    navOptions: navigationOptions
                };
            }
            // Other Authority
            //  -> Home
            // protocolLaunchOptions.error = new Error("Unsupported deep-link location");
            // protocolLaunchOptions.error.code = "DL003";


            return protocolLaunchOptions;
        }
    });
})();