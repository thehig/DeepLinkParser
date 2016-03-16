require('../app/deepLinkParser');
expect = require('chai').expect

describe "000.init", ->
	it "should create the Rainfall.Utilities.DeepLinkParser Namespace", ->
		expect(Rainfall.Utilities.DeepLinkParser).to.exist
	it "should have the parseDeeplinkActivation function", ->
		expect(Rainfall.Utilities.DeepLinkParser.parseDeeplinkActivation).to.exist
	it "should create the XboxJS.Navigation Namespace", ->
		expect(XboxJS.Navigation).to.exist
	it "should have the parseProtocolActivation function", ->
		expect(XboxJS.Navigation.parseProtocolActivation).to.exist