require('../app/deepLinkParser');
expect = require('chai').expect
w = console.log

parse = MyApp.Utilities.RainfallDeepLink.parseDeepLink
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

	describe "blank authority", ->
		it "should not have an error", -> expect(parse(args)).to.not.have.property('error')

	describe "should return DL001 for invalid authority", ->
		it "vonbismark", ->
			args.detail.uri.host = 'vonbismark'
			expect(parse(args).error).to.have.property('code', 'DL001')
		it "99vonb", ->
			args.detail.uri.host = '99vonb'
			expect(parse(args).error).to.have.property('code', 'DL001')

	# describe "when given contentType='tvSeries' and contentId='289'", ->
	# 	beforeEach -> 
	# 		args.detail.uri.host = 'media-details'

	# 		args.detail.uri.queryParsed.push({name: 'contentId',value: 289})
	# 		args.detail.uri.queryParsed.push({name: 'contentType',value: 'tvSeries'})

	# 	it "should return a postProcess", ->
	# 		r = parse(args)
	# 		w(r)
	# 		expect(r).to.have.property('postProcess')