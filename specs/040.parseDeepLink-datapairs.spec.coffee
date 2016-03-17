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

	describe "should return error DL003 if given media-details, contentId 289 and contentType", ->
		beforeEach -> 
			args.detail.uri.host = 'media-details'			
			args.detail.uri.queryParsed.push({name: 'contentId',value: '289'})

		it "undefined", ->
			expect(parse(args).error).to.have.property('code', 'DL003')
		it "album", ->
			args.detail.uri.queryParsed.push({name: 'contentType',value: 'album'})
			expect(parse(args).error).to.have.property('code', 'DL003')
		it "movie", ->
			args.detail.uri.queryParsed.push({name: 'contentType',value: 'movie'})
			expect(parse(args).error).to.have.property('code', 'DL003')
		it "musicArtist", ->
			args.detail.uri.queryParsed.push({name: 'contentType',value: 'musicArtist'})
			expect(parse(args).error).to.have.property('code', 'DL003')
		it "track", ->
			args.detail.uri.queryParsed.push({name: 'contentType',value: 'track'})
			expect(parse(args).error).to.have.property('code', 'DL003')
		it "tvShow", ->
			args.detail.uri.queryParsed.push({name: 'contentType',value: 'tvShow'})
			expect(parse(args).error).to.have.property('code', 'DL003')
		it "webVideo", ->
			args.detail.uri.queryParsed.push({name: 'contentType',value: 'webVideo'})
			expect(parse(args).error).to.have.property('code', 'DL003')
		it "webVideoCollection", ->
			args.detail.uri.queryParsed.push({name: 'contentType',value: 'webVideoCollection'})
			expect(parse(args).error).to.have.property('code', 'DL003')
		it "vonbismark", ->
			args.detail.uri.queryParsed.push({name: 'contentType',value: 'vonbismark'})
			expect(parse(args).error).to.have.property('code', 'DL003')
		it "99vonb", ->	
			args.detail.uri.queryParsed.push({name: 'contentType',value: '99vonb'})
			expect(parse(args).error).to.have.property('code', 'DL003')

	describe "should return a valid contentType if given contentId 289 and ", ->
		beforeEach -> 
			args.detail.uri.queryParsed.push({name: 'contentId',value: '289'})			
			args.detail.uri.host = 'media-details'

		it "media-details/tvSeries", ->
			args.detail.uri.queryParsed.push({name: 'contentType',value: 'tvSeries'})
			expect(parse(args)).to.have.property('contentType', XboxJS.Data.ContentType.tvSeries)
		it "media-details/tvSeason", ->
			args.detail.uri.queryParsed.push({name: 'contentType',value: 'tvSeason'})
			expect(parse(args)).to.have.property('contentType', XboxJS.Data.ContentType.tvSeason)
		it "media-details/tvEpisode", ->
			args.detail.uri.queryParsed.push({name: 'contentType',value: 'tvEpisode'})
			expect(parse(args)).to.have.property('contentType', XboxJS.Data.ContentType.tvEpisode)