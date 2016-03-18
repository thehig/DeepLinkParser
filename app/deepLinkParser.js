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
        parseAuthority: function(args){
            // Set up the default location
            var protocolLaunchOptions = {
                locationName: XboxJS.Navigation.LocationName.mediaHomeUri
            };

            // Check the host, blank should just go home
            var host = args.detail.uri.host;
            if(!host) return protocolLaunchOptions;

            // Parse and store the args
            var protocolActivation = XboxJS.Navigation.parseProtocolActivation(args);
            protocolLaunchOptions.parsedActivation = protocolActivation;

            // No protocol activation means the authority was invalid or unrecognised
            if(!protocolActivation) {
                return protocolLaunchOptions;
            }

            // Store the parsed locationName from above. This should cover missing contentId
            protocolLaunchOptions.locationName = protocolActivation.locationName;

            // If the location says home, we return home
            if(protocolLaunchOptions.locationName === XboxJS.Navigation.LocationName.mediaHomeUri)
                return protocolLaunchOptions;

            // After the above, we know we have a deep-link that does not direct to the home page.
            //  we redirect all links past this point, to the media-details page (covers media-playback)
            if(protocolLaunchOptions.locationName !== XboxJS.Navigation.LocationName.mediaDetailsUri)
                protocolLaunchOptions.locationName = XboxJS.Navigation.LocationName.mediaDetailsUri;

            return protocolLaunchOptions;
        },
        parseDataPair: function(protocolLaunchOptions){
            // locationName is definitely mediaDetailsUri
            // contentId is definitely present, but not necessarily valid
            // contentType is unknown

            var contentId = parseInt(protocolLaunchOptions.parsedActivation.options.contentId);
            if(!contentId || contentId < 1) {                
                protocolLaunchOptions.error = new Error("Invalid or unrecognised contentId");
                protocolLaunchOptions.error.code = "DL002";
                return protocolLaunchOptions;
            }

            // contentId is definitely a positive integer
            protocolLaunchOptions.contentId = contentId;

            // Now we check the contentType
            var contentType = protocolLaunchOptions.parsedActivation.options.contentType;
            if(!contentType || (contentType !== XboxJS.Data.ContentType.tvSeries &&
                                contentType !== XboxJS.Data.ContentType.tvSeason &&
                                contentType !== XboxJS.Data.ContentType.tvEpisode)){
                protocolLaunchOptions.error = new Error("Invalid or unsupported contentType");
                protocolLaunchOptions.error.code = "DL003";
                return protocolLaunchOptions;
            }

            // contentType is definitely tvSeries, tvSeason or tvEpisode
            protocolLaunchOptions.contentType = contentType;

            // This forms a valid data pair
            return protocolLaunchOptions;
        },
        parseValidLink: function(protocolLaunchOptions){
            var navigationUri = undefined;
            var navigationOptions = undefined;

            var contentId = protocolLaunchOptions.contentId;
            var contentType = protocolLaunchOptions.contentType;

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
                            }, function (err) {
                                err.code = "DL007";
                                throw err;
                            }).then(null, deepLinkError);
                        }
                    }
                    break;

                default:
                    break;
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

        parseDeepLink: function(args){
            var authority = MyApp.Utilities.RainfallDeepLink.parseAuthority(args);
            if(authority.error || authority.locationName === XboxJS.Navigation.LocationName.mediaHomeUri)
                return authority;

            var dataPair = MyApp.Utilities.RainfallDeepLink.parseDataPair(authority);
            if(dataPair.error || dataPair.locationName === XboxJS.Navigation.LocationName.mediaHomeUri)
                return dataPair;

            dataPair.postprocess = MyApp.Utilities.RainfallDeepLink.parseValidLink(dataPair);
            return dataPair;
        }
    });
})();
