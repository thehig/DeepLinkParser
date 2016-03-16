if (typeof module != 'undefined' && module.exports) {
    WinJS = require("node-winjs");
    require("./lib/XboxJS.Navigation");
}

(function deepLinkParserInit(global){
	"use strict";
	var self = this;

	WinJS.Namespace.define("Rainfall.Utilities.DeepLinkParser", {
		parseDeeplinkActivation: function(args){
			
		}
	});
})(this);