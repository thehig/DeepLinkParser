require('../app/deepLinkParser');
expect = require('chai').expect
w = console.log

parse = MyApp.Utilities.RainfallDeepLink.parseDeepLink
locationName = XboxJS.Navigation.LocationName

describe "040. Data Pair Parsing - MyApp.Utilities.RainfallDeepLink.parseDeepLink", ->
	args = undefined
	beforeEach ->
		# Since we don't have the Xbox to parse the deepLink for us, 
		#  this is the closest I'm bothered getting in mirroring it
		args = detail:
		  kind: {}
		  uri:
		    host: ''
		    queryParsed: []
	
	describe "should return mediaHomeUri if given no contentId with authority", ->
		expected = locationName.mediaHomeUri
		it "media-details", ->
			args.detail.uri.host = 'media-details'
			expect(parse(args)).to.have.property('locationName', expected)
		it "media-playback", ->
			args.detail.uri.host = 'media-playback'
			expect(parse(args)).to.have.property('locationName', expected)

	describe "should return error DL002 if given media-details and", ->
		beforeEach -> args.detail.uri.host = 'media-details'
		it "contentId is not castable to int", ->
			args.detail.uri.queryParsed.push({name: 'contentId',value: 'requiredValue'})
			expect(parse(args).error).to.have.property('code', 'DL002')
		it "contentId is a negative number", ->
			args.detail.uri.queryParsed.push({name: 'contentId',value: '-12'})
			expect(parse(args).error).to.have.property('code', 'DL002')
		it "contentId is 0", ->
			args.detail.uri.queryParsed.push({name: 'contentId',value: '0'})
			expect(parse(args).error).to.have.property('code', 'DL002')

