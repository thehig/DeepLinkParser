require('../app/deepLinkParser');
expect = require('chai').expect
w = console.log

parse = MyApp.Utilities.RainfallDeepLink.parseDeepLinkMoreBetterer
locationName = XboxJS.Navigation.LocationName

describe.skip "** rewrite in progress** 030. MyApp.Utilities.RainfallDeepLink.parseDeepLink", ->
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

	describe "when given contentType='tvSeries' and contentId='289'", ->
		beforeEach -> 
			args.detail.uri.host = 'media-details'

			args.detail.uri.queryParsed.push({name: 'contentId',value: 289})
			args.detail.uri.queryParsed.push({name: 'contentType',value: 'tvSeries'})

		it "should return a postProcess", ->
			r = parse(args)
			w(r)
			expect(r).to.have.property('postProcess')