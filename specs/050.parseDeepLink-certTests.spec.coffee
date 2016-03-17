require('../app/deepLinkParser');
expect = require('chai').expect
w = console.log

parse = MyApp.Utilities.RainfallDeepLink.parseDeepLink
locationName = XboxJS.Navigation.LocationName

describe "050. Certification Tests - MyApp.Utilities.RainfallDeepLink.parseDeepLink", ->
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

	describe "Data Pairs", ->
		describe "should go to mediaDetailsUri given", ->
			parsedActivation = undefined

			afterEach ->
				expect(parsedActivation).to.have.property('locationName', locationName.mediaDetailsUri)
				expect(parsedActivation).to.have.property('contentId', 289)

			describe "media-playback", ->
				beforeEach ->
					args.detail.uri.host = 'media-playback'

				describe "contentType/289", ->
					it "tvSeries", ->
						args.detail.uri.queryParsed.push({name: 'contentType',value: 'tvSeries'})
						args.detail.uri.queryParsed.push({name: 'contentId',value: '289'})
						parsedActivation = parse(args) 
						expect(parsedActivation).to.have.property('contentType', XboxJS.Data.ContentType.tvSeries)
					it "tvSeason", ->
						args.detail.uri.queryParsed.push({name: 'contentType',value: 'tvSeason'})
						args.detail.uri.queryParsed.push({name: 'contentId',value: '289'})
						parsedActivation = parse(args) 
						expect(parsedActivation).to.have.property('contentType', XboxJS.Data.ContentType.tvSeason)
					it "tvEpisode", ->
						args.detail.uri.queryParsed.push({name: 'contentType',value: 'tvEpisode'})
						args.detail.uri.queryParsed.push({name: 'contentId',value: '289'})
						parsedActivation = parse(args) 
						expect(parsedActivation).to.have.property('contentType', XboxJS.Data.ContentType.tvEpisode)

				describe "289/contentType", ->
					it "tvSeries", ->
						args.detail.uri.queryParsed.push({name: 'contentId',value: '289'})
						args.detail.uri.queryParsed.push({name: 'contentType',value: 'tvSeries'})
						parsedActivation = parse(args)
						expect(parsedActivation).to.have.property('contentType', XboxJS.Data.ContentType.tvSeries)
					it "tvSeason", ->
						args.detail.uri.queryParsed.push({name: 'contentId',value: '289'})
						args.detail.uri.queryParsed.push({name: 'contentType',value: 'tvSeason'})
						parsedActivation = parse(args)
						expect(parsedActivation).to.have.property('contentType', XboxJS.Data.ContentType.tvSeason)
					it "tvEpisode", ->
						args.detail.uri.queryParsed.push({name: 'contentId',value: '289'})
						args.detail.uri.queryParsed.push({name: 'contentType',value: 'tvEpisode'})
						parsedActivation = parse(args)
						expect(parsedActivation).to.have.property('contentType', XboxJS.Data.ContentType.tvEpisode)

			describe "media-details", ->
				beforeEach ->
					args.detail.uri.host = 'media-details'

				describe "contentType/289", ->
					it "tvSeries", ->
						args.detail.uri.queryParsed.push({name: 'contentType',value: 'tvSeries'})
						args.detail.uri.queryParsed.push({name: 'contentId',value: '289'})
						parsedActivation = parse(args) 
						expect(parsedActivation).to.have.property('contentType', XboxJS.Data.ContentType.tvSeries)
					it "tvSeason", ->
						args.detail.uri.queryParsed.push({name: 'contentType',value: 'tvSeason'})
						args.detail.uri.queryParsed.push({name: 'contentId',value: '289'})
						parsedActivation = parse(args) 
						expect(parsedActivation).to.have.property('contentType', XboxJS.Data.ContentType.tvSeason)
					it "tvEpisode", ->
						args.detail.uri.queryParsed.push({name: 'contentType',value: 'tvEpisode'})
						args.detail.uri.queryParsed.push({name: 'contentId',value: '289'})
						parsedActivation = parse(args) 
						expect(parsedActivation).to.have.property('contentType', XboxJS.Data.ContentType.tvEpisode)

				describe "289/contentType", ->
					it "tvSeries", ->
						args.detail.uri.queryParsed.push({name: 'contentId',value: '289'})
						args.detail.uri.queryParsed.push({name: 'contentType',value: 'tvSeries'})
						parsedActivation = parse(args)
						expect(parsedActivation).to.have.property('contentType', XboxJS.Data.ContentType.tvSeries)
					it "tvSeason", ->
						args.detail.uri.queryParsed.push({name: 'contentId',value: '289'})
						args.detail.uri.queryParsed.push({name: 'contentType',value: 'tvSeason'})
						parsedActivation = parse(args)
						expect(parsedActivation).to.have.property('contentType', XboxJS.Data.ContentType.tvSeason)
					it "tvEpisode", ->
						args.detail.uri.queryParsed.push({name: 'contentId',value: '289'})
						args.detail.uri.queryParsed.push({name: 'contentType',value: 'tvEpisode'})
						parsedActivation = parse(args)
						expect(parsedActivation).to.have.property('contentType', XboxJS.Data.ContentType.tvEpisode)

	describe "Error Handling", ->
		describe "Malformed", ->
			describe "DL001", ->
				it "invalid authority 99vonb", ->
					args.detail.uri.host = '99vonb'
					expect(parse(args).error).to.have.property('code', 'DL001')
				it "invalid authority vonbismark", ->
					args.detail.uri.host = 'vonbismark'
					expect(parse(args).error).to.have.property('code', 'DL001')
			describe "Home", ->
				it "unsupported authority media-search", ->
					args.detail.uri.host = 'media-search'
					expect(parse(args)).to.have.property('locationName', locationName.mediaHomeUri)
				it "unsupported authority media-help", ->
					args.detail.uri.host = 'media-help'
					expect(parse(args)).to.have.property('locationName', locationName.mediaHomeUri)
				it "unsupported authority media-settings", ->
					args.detail.uri.host = 'media-settings'
					expect(parse(args)).to.have.property('locationName', locationName.mediaHomeUri)
		describe "Missing or invalid content pair", ->
			beforeEach -> args.detail.uri.host = 'media-details'	
			describe "DL002 - ContentID", ->
				it "string", ->
					args.detail.uri.queryParsed.push({name: 'contentId',value: 'one'})
					expect(parse(args).error).to.have.property('code', 'DL002')
				it "negative", ->
					args.detail.uri.queryParsed.push({name: 'contentId',value: '-4'})
					expect(parse(args).error).to.have.property('code', 'DL002')
			describe "DL003 - ContentType", ->
				beforeEach -> args.detail.uri.queryParsed.push({name: 'contentId',value: '289'})
				it "missing", ->
					expect(parse(args).error).to.have.property('code', 'DL003')
				describe "invalid value", ->
					it "99vonb", ->
						args.detail.uri.queryParsed.push({name: 'contentType',value: '99vonb'})
						expect(parse(args).error).to.have.property('code', 'DL003')
					it "vonbismark", ->
						args.detail.uri.queryParsed.push({name: 'contentType',value: 'vonbismark'})
						expect(parse(args).error).to.have.property('code', 'DL003')
				describe "unsupported value", ->
					it "album", ->
						args.detail.uri.queryParsed.push({name: 'contentType',value: 'album'})
						expect(parse(args).error).to.have.property('code', 'DL003')
					it "track", ->
						args.detail.uri.queryParsed.push({name: 'contentType',value: 'track'})
						expect(parse(args).error).to.have.property('code', 'DL003')
					it "webCollection", ->
						args.detail.uri.queryParsed.push({name: 'contentType',value: 'webCollection'})
						expect(parse(args).error).to.have.property('code', 'DL003')
		describe.skip "DL004 - Invalid/missing content", ->
			it "** Requires DataProvider **", ->

	describe.skip "Dynamic Support", ->
		it "** Requires Xbox **", ->
	describe.skip "Without Credentials", ->
		it "** Requires Xbox **", ->

