require('../app/deepLinkParser');
expect = require('chai').expect
w = console.log

parse = MyApp.Utilities.RainfallDeepLink.parseDeepLinkMoreBetterer
locationName = XboxJS.Navigation.LocationName

describe "030. MyApp.Utilities.RainfallDeepLink.parseDeepLink", ->
	args = undefined
	beforeEach ->
		# Since we don't have the Xbox to parse the deepLink for us, 
		#  this is the closest I'm bothered getting in mirroring it
		args = detail:
		  kind: {}
		  uri:
		    host: ''
		    queryParsed: []

	describe "should return error for unrecognised authority", ->
		it "blank", -> expect(parse(args)).to.have.property('error')
		it "vonbismark", ->
			args.detail.uri.host = 'vonbismark'
			expect(parse(args)).to.have.property('error')
		it "99vonb", ->
			args.detail.uri.host = '99vonb'
			expect(parse(args)).to.to.have.property('error')	