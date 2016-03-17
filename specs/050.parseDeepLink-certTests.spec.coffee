require('../app/deepLinkParser');
expect = require('chai').expect
w = console.log

parse = MyApp.Utilities.RainfallDeepLink.parseDeepLink
locationName = XboxJS.Navigation.LocationName

describe.only "050. Certification Tests - MyApp.Utilities.RainfallDeepLink.parseDeepLink", ->
	args = undefined
	beforeEach ->
		# Since we don't have the Xbox to parse the deepLink for us, 
		#  this is the closest I'm bothered getting in mirroring it
		args = detail:
		  kind: {}
		  uri:
		    host: ''
		    queryParsed: []

	describe "Authorities", ->
		it "must support blank to home", ->
			expect(parse(args)).to.have.property('locationName', locationName.mediaHomeUri)
		it "must support default to home", ->
			args.detail.uri.host = 'default'
			expect(parse(args)).to.have.property('locationName', locationName.mediaHomeUri)
		it "media-settings to home if not supported", ->
			args.detail.uri.host = 'media-settings'
			expect(parse(args)).to.have.property('locationName', locationName.mediaHomeUri)
		it "media-help to home if not supported", ->
			args.detail.uri.host = 'media-help'
			expect(parse(args)).to.have.property('locationName', locationName.mediaHomeUri)
		it "media-search to home if not supported", ->
			args.detail.uri.host = 'media-search'
			expect(parse(args)).to.have.property('locationName', locationName.mediaHomeUri)

		describe "with no contentId but authority", ->
			it "media-details to home", ->
				args.detail.uri.host = 'media-details'
				expect(parse(args)).to.have.property('locationName', locationName.mediaHomeUri)
			it "media-playback to home", ->
				args.detail.uri.host = 'media-playback'
				expect(parse(args)).to.have.property('locationName', locationName.mediaHomeUri)

		describe "with contentId 289, contentType tvSeries and authority", ->
			beforeEach -> 
				args.detail.uri.queryParsed.push({name: 'contentId',value: '289'})
				args.detail.uri.queryParsed.push({name: 'contentType',value: 'tvSeries'})
			it "media-details to content", ->
				args.detail.uri.host = 'media-details'
				expect(parse(args)).to.have.property('locationName', locationName.mediaDetailsUri)
				expect(parse(args)).to.have.property('contentId', 289)
				expect(parse(args)).to.have.property('contentType', XboxJS.Data.ContentType.tvSeries)
			it "media-playback to content", ->
				args.detail.uri.host = 'media-playback'
				expect(parse(args)).to.have.property('locationName', locationName.mediaDetailsUri)
				expect(parse(args)).to.have.property('contentId', 289)
				expect(parse(args)).to.have.property('contentType', XboxJS.Data.ContentType.tvSeries)