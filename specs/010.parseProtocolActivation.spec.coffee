require('../app/deepLinkParser');
expect = require('chai').expect
w = console.log

parse = XboxJS.Navigation.parseProtocolActivation
locationName = XboxJS.Navigation.LocationName

describe "010. XboxJS.Navigation.parseProtocolActivation", ->
	args = undefined
	beforeEach ->
		# Since we don't have the Xbox to parse the deepLink for us, 
		#  this is the closest I'm bothered getting in mirroring it
		args = detail:
		  kind: {}
		  uri:
		    host: ''
		    queryParsed: []

	describe "should return home if no contentId is passed to authority", ->
		it "default", ->
			args.detail.uri.host = 'default'
			expect(parse(args)).to.have.property('locationName', locationName.mediaHomeUri)
		it "media-details", ->
			args.detail.uri.host = 'media-details'
			expect(parse(args)).to.have.property('locationName', locationName.mediaHomeUri)
		it "media-playback", ->
			args.detail.uri.host = 'media-playback'
			expect(parse(args)).to.have.property('locationName', locationName.mediaHomeUri)
		it "media-settings", ->
			args.detail.uri.host = 'media-settings'
			expect(parse(args)).to.have.property('locationName', locationName.mediaHomeUri)
		it "media-help", ->
			args.detail.uri.host = 'media-help'
			expect(parse(args)).to.have.property('locationName', locationName.mediaHomeUri)
		it "media-search", ->
			args.detail.uri.host = 'media-search'
			expect(parse(args)).to.have.property('locationName', locationName.mediaHomeUri)

	describe "should return appropriate location if provided contentId with authority", ->
		beforeEach -> # Add any contentId at all
			args.detail.uri.queryParsed.push({name: 'contentId',value: 'requiredValue'})

		it "default", ->
			args.detail.uri.host = 'default'
			expect(parse(args)).to.have.property('locationName', locationName.mediaHomeUri)
		it "media-details", ->
			args.detail.uri.host = 'media-details'
			expect(parse(args)).to.have.property('locationName', locationName.mediaDetailsUri)
		it "media-playback", ->
			args.detail.uri.host = 'media-playback'
			expect(parse(args)).to.have.property('locationName', locationName.mediaPlaybackUri)
		it "media-settings", ->
			args.detail.uri.host = 'media-settings'
			expect(parse(args)).to.have.property('locationName', locationName.mediaSettingsUri)
		it "media-help", ->
			args.detail.uri.host = 'media-help'
			expect(parse(args)).to.have.property('locationName', locationName.mediaHelpUri)
		it "media-search", ->
			args.detail.uri.host = 'media-search'
			expect(parse(args)).to.have.property('locationName', locationName.mediaSearchUri)

	describe "should return undefined for unrecognised authority", ->
		it "blank", -> expect(parse(args)).to.be.undefined
		it "vonbismark", ->
			args.detail.uri.host = 'vonbismark'
			expect(parse(args)).to.be.undefined
		it "99vonb", ->
			args.detail.uri.host = '99vonb'
			expect(parse(args)).to.be.undefined

	describe "should parse recognised query params", ->
		beforeEach -> # Add recognised queryParams contentId, contentType and deepLinkInfo
			args.detail.uri.host = 'media-details'
			args.detail.uri.queryParsed.push({name: 'contentId',value: 'requiredValue'})
			args.detail.uri.queryParsed.push({name: 'contentType',value: 'anythingAtAll'})
			args.detail.uri.queryParsed.push({name: 'deepLinkInfo',value: 'WhateverYouWant'})

		it "contentId", -> expect(parse(args).options).to.have.property('contentId', 'requiredValue')
		it "contentType", -> expect(parse(args).options).to.have.property('contentType', 'anythingAtAll')
		it "deepLinkInfo", -> expect(parse(args).options).to.have.property('deepLinkInfo', 'WhateverYouWant')

	describe "should ignore unrecognised params", ->
		beforeEach -> # Add stupid queryParams
			args.detail.uri.host = 'media-details'
			args.detail.uri.queryParsed.push({name: 'thisShouldBeIgnored',value: 'ShouldBeIgnored'})
			args.detail.uri.queryParsed.push({name: 'soShouldThis',value: 'ShouldBeIgnored'})

		it "thisShouldBeIgnored", -> expect(parse(args).options).to.not.have.property('thisShouldBeIgnored')
		it "soShouldThis", -> expect(parse(args).options).to.not.have.property('soShouldThis')

