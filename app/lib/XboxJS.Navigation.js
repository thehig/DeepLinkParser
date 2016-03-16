if (typeof module != 'undefined' && module.exports) {
    WinJS = require("node-winjs");
}
// Activation Services, from Xbox.js:13

(function activationServicesInit(WinJS, XboxJS) {
    "use strict";

    WinJS.Namespace.define("XboxJS.Navigation", {
        /// <field type="String" locid="XboxJS.UI.Navigation.LocationName" helpKeyword="XboxJS.UI.Navigation.LocationName">
        /// An enumeration of location names returned as part of parseProtocolActivation()
        /// </field>
        LocationName: {
            mediaHelpUri: "mediaHelpUri",
            mediaHomeUri: "mediaHomeUri",
            mediaPlaybackUri: "mediaPlaybackUri",
            mediaSearchUri: "mediaSearchUri",
            mediaSettingsUri: "mediaSettingsUri",
            mediaDetailsUri: "mediaDetailsUri",
        },

        parseProtocolActivation: WinJS.Namespace._lazy(function () {
            var activation = null;
            if (WinJS.Utilities.hasWinRT) {
                activation = Windows.ApplicationModel.Activation;
            }

            var _defaultAuthority = "default";
            var _mediaDetailsAuthority = "media-details";
            var _mediaHelpAuthority = "media-help";
            var _mediaPlaybackAuthority = "media-playback";
            var _mediaSearchAuthority = "media-search";
            var _mediaSettingsAuthority = "media-settings";

            var _contentIdArgument = "contentId";
            var _catalogDataArgument = "catalogData";

            var _playbackPage = "playback";
            var _detailsPage = "details";

            var _contentIdKey = "contentid";
            var _deepLinkInfoKey = "deeplinkinfo";
            var _contentTypeKey = "contenttype";

            return function activationServices_parseProtocolActivation(protocolActivationEventArguments) {
                /// <signature helpKeyword="XboxJS.Navigation.parseProtocolActivation">
                /// <summary locid="XboxJS.Navigation.parseProtocolActivation">
                /// Parse a deep link messages from the system.
                /// </summary>
                /// <param name="protocolActivationEventArguments" type="Object" locid="XboxJS.Navigation.handleProtocolActivation:protocolActivationEventArguments">
                /// The event object from the WinJS.Application.onactivated event.
                /// </param>
                /// </signature>
                /// <return value="{locationName:'', options: {contentId: '', authority: '', contentType: '', catalogData: ''}}" locid="XboxJS.Navigation.parseProtocolActivation_returns">
                /// Returns undefined if protocolActivationEventArguments is not from a protocol activation or if the activation URI is unrecoginized. Otherise,
                /// returns the location name requested and the options to pass to WinJS.Navigation.navigate().
                /// </return>
                if (protocolActivationEventArguments &&
                    protocolActivationEventArguments.detail.kind === activation.ActivationKind.protocol) {

                    // Uri format: xbl-<title id>://<authority>/?contentId=123456&contentType=Movie&catalogData=<app specific data>
                    var activationUri = protocolActivationEventArguments.detail.uri;

                    // If we are instructed to go to the details page
                    var authority = activationUri.host;
                    var caseInsensitiveAuthority = authority.toLowerCase();
                    if (caseInsensitiveAuthority === _defaultAuthority.toLowerCase() ||
                        caseInsensitiveAuthority === _mediaDetailsAuthority.toLowerCase() ||
                        caseInsensitiveAuthority === _mediaHelpAuthority.toLowerCase() ||
                        caseInsensitiveAuthority === _mediaPlaybackAuthority.toLowerCase() ||
                        caseInsensitiveAuthority === _mediaSearchAuthority.toLowerCase() ||
                        caseInsensitiveAuthority === _mediaSettingsAuthority.toLowerCase()) {

                        var queryArgs = activationUri.queryParsed;
                        var locationName = "";
                        var contentId = "";
                        var deepLinkInfo = "";
                        var contentType = "";
                        for (var i = 0; i < queryArgs.size; i++) {
                            var caseInsensitiveQueryArg = queryArgs[i].name.toLowerCase();
                            switch (caseInsensitiveQueryArg) {
                                case _contentIdKey.toLowerCase():
                                    contentId = queryArgs[i].value;
                                    break;
                                case _deepLinkInfoKey.toLowerCase():
                                    deepLinkInfo = queryArgs[i].value;
                                    break;
                                case _contentTypeKey.toLowerCase():
                                    contentType = queryArgs[i].value;
                                    break;
                                default:
                                    break;
                            }
                        }

                        var locationName = this.LocationName;

                        // In case the contentId is null or empty we go to the app's homepage
                        if (!contentId)
                            locationName = locationName.mediaHomeUri;
                        else {
                            switch (caseInsensitiveAuthority) {
                                case _defaultAuthority.toLowerCase():
                                    locationName = locationName.mediaHomeUri;
                                    break;
                                case _mediaDetailsAuthority.toLowerCase():
                                    locationName = locationName.mediaDetailsUri;
                                    break;
                                case _mediaPlaybackAuthority.toLowerCase():
                                    locationName = locationName.mediaPlaybackUri;
                                    break;
                                case _mediaHelpAuthority.toLowerCase():
                                    locationName = locationName.mediaHelpUri;
                                    break;
                                case _mediaSearchAuthority.toLowerCase():
                                    locationName = locationName.mediaSearchUri;
                                    break;
                                case _mediaSettingsAuthority.toLowerCase():
                                    locationName = locationName.mediaSettingsUri;
                                    break;
                                default:
                                    // No-op for unknown authorities
                                    break;
                            }
                        }

                        if (locationName)
                            return {
                                locationName: locationName,
                                options: {
                                    contentId: contentId,
                                    authority: authority,
                                    deepLinkInfo: deepLinkInfo,
                                    contentType: contentType,
                                }
                            };
                    }
                }
            };
        })
    });
})(WinJS);