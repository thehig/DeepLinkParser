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
		describe "should go to mediaHomeUri if authority is", ->
			it "blank", ->
				expect(parse(args)).to.have.property('locationName', locationName.mediaHomeUri)
			it "default", ->
				args.detail.uri.host = 'default'
				expect(parse(args)).to.have.property('locationName', locationName.mediaHomeUri)

		describe "should go to mediaHomeUri if required but unsupported authority", ->
			it "media-settings", ->
				args.detail.uri.host = 'media-settings'
				expect(parse(args)).to.have.property('locationName', locationName.mediaHomeUri)
			it "media-help", ->
				args.detail.uri.host = 'media-help'
				expect(parse(args)).to.have.property('locationName', locationName.mediaHomeUri)
			it "media-search", ->
				args.detail.uri.host = 'media-search'
				expect(parse(args)).to.have.property('locationName', locationName.mediaHomeUri)

		describe "should go to mediaHomeUri with no contentId and authority", ->
			it "media-details", ->
				args.detail.uri.host = 'media-details'
				expect(parse(args)).to.have.property('locationName', locationName.mediaHomeUri)
			it "media-playback", ->
				args.detail.uri.host = 'media-playback'
				expect(parse(args)).to.have.property('locationName', locationName.mediaHomeUri)

		describe "should go to mediaDetailsUri with contentId 289", ->
			beforeEach -> args.detail.uri.queryParsed.push({name: 'contentId',value: '289'})
			describe "contentType tvSeries", ->
				beforeEach -> args.detail.uri.queryParsed.push({name: 'contentType',value: 'tvSeries'})
				describe "and authority", ->
					it "media-details", ->
						args.detail.uri.host = 'media-details'
						parsedActivation = parse(args) 
						expect(parsedActivation).to.have.property('locationName', locationName.mediaDetailsUri)
						expect(parsedActivation).to.have.property('contentId', 289)
						expect(parsedActivation).to.have.property('contentType', XboxJS.Data.ContentType.tvSeries)
					it "media-playback", ->
						args.detail.uri.host = 'media-playback'
						parsedActivation = parse(args) 
						expect(parsedActivation).to.have.property('locationName', locationName.mediaDetailsUri)
						expect(parsedActivation).to.have.property('contentId', 289)
						expect(parsedActivation).to.have.property('contentType', XboxJS.Data.ContentType.tvSeries)
			describe "contentType tvSeason", ->
				beforeEach -> args.detail.uri.queryParsed.push({name: 'contentType',value: 'tvSeason'})
				describe " and authority", ->
					it "media-details", ->
						args.detail.uri.host = 'media-details'
						parsedActivation = parse(args) 
						expect(parsedActivation).to.have.property('locationName', locationName.mediaDetailsUri)
						expect(parsedActivation).to.have.property('contentId', 289)
						expect(parsedActivation).to.have.property('contentType', XboxJS.Data.ContentType.tvSeason)
					it "media-playback", ->
						args.detail.uri.host = 'media-playback'
						parsedActivation = parse(args) 
						expect(parsedActivation).to.have.property('locationName', locationName.mediaDetailsUri)
						expect(parsedActivation).to.have.property('contentId', 289)
						expect(parsedActivation).to.have.property('contentType', XboxJS.Data.ContentType.tvSeason)
			describe "contentType tvEpisode", ->
				beforeEach -> args.detail.uri.queryParsed.push({name: 'contentType',value: 'tvEpisode'})
				describe " and authority", ->
					it "media-details", ->
						args.detail.uri.host = 'media-details'
						parsedActivation = parse(args) 
						expect(parsedActivation).to.have.property('locationName', locationName.mediaDetailsUri)
						expect(parsedActivation).to.have.property('contentId', 289)
						expect(parsedActivation).to.have.property('contentType', XboxJS.Data.ContentType.tvEpisode)
					it "media-playback", ->
						args.detail.uri.host = 'media-playback'
						parsedActivation = parse(args) 
						expect(parsedActivation).to.have.property('locationName', locationName.mediaDetailsUri)
						expect(parsedActivation).to.have.property('contentId', 289)
						expect(parsedActivation).to.have.property('contentType', XboxJS.Data.ContentType.tvEpisode)
