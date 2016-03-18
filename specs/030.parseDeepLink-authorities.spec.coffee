require('../app/deepLinkParser');
expect = require('chai').expect
w = console.log

parse = MyApp.Utilities.RainfallDeepLink.parseDeepLink
locationName = XboxJS.Navigation.LocationName

describe "030. Authority Parsing - MyApp.Utilities.RainfallDeepLink.parseDeepLink", ->
	args = undefined
	beforeEach ->
		# Since we don't have the Xbox to parse the deepLink for us, 
		#  this is the closest I'm bothered getting in mirroring it
		args = detail:
		  kind: {}
		  uri:
		    host: ''
		    queryParsed: []
	
	it "should not have an error for blank authority", -> expect(parse(args)).to.not.have.property('error')

	describe "should get mediaHomeUri from authorities ", ->
		expected = locationName.mediaHomeUri

		it "blank", ->
			expect(parse(args)).to.have.property('locationName', expected)
		it "default", ->
			args.detail.uri.host = 'default'
			expect(parse(args)).to.have.property('locationName', expected)
		it "media-help", ->
			args.detail.uri.host = 'media-help'
			expect(parse(args)).to.have.property('locationName', expected)
		it "media-settings", ->
			args.detail.uri.host = 'media-settings'
			expect(parse(args)).to.have.property('locationName', expected)
		it "media-search", ->
			args.detail.uri.host = 'media-search'
			expect(parse(args)).to.have.property('locationName', expected)
		it "vonbismark", ->
			args.detail.uri.host = 'vonbismark'
			expect(parse(args)).to.not.have.property('error')
			expect(parse(args)).to.have.property('locationName', locationName.mediaHomeUri)
		it "99vonb", ->
			args.detail.uri.host = '99vonb'
			expect(parse(args)).to.not.have.property('error')
			expect(parse(args)).to.have.property('locationName', locationName.mediaHomeUri)

	describe "should get mediaDetailsUri from authorities (with contentId)", ->
		expected = locationName.mediaDetailsUri
		beforeEach -> # Add required queryParam contentId, otherwise everything will go to mediaHomeUri
			args.detail.uri.queryParsed.push({name: 'contentId',value: 'requiredValue'})

		it "media-details", ->
			args.detail.uri.host = 'media-details'
			expect(parse(args)).to.have.property('locationName', expected)
		it "media-playback", ->
			args.detail.uri.host = 'media-playback'
			expect(parse(args)).to.have.property('locationName', expected)
