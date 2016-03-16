require('../app/deepLinkParser');
expect = require('chai').expect

describe "000.init", ->
	it "should create the MyApp.Utilities.RainfallDeepLink Namespace", ->
		expect(MyApp.Utilities.RainfallDeepLink).to.exist
	it "should have the parseDeepLinkMoreBetterer function", ->
		expect(MyApp.Utilities.RainfallDeepLink.parseDeepLinkMoreBetterer).to.exist
	it "should create the XboxJS.Navigation Namespace", ->
		expect(XboxJS.Navigation).to.exist
	it "should have the parseProtocolActivation function", ->
		expect(XboxJS.Navigation.parseProtocolActivation).to.exist