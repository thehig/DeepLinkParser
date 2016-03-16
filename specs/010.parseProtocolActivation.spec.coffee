require('../app/deepLinkParser');
expect = require('chai').expect
w = console.log

parse = XboxJS.Navigation.parseProtocolActivation
locationName = XboxJS.Navigation.LocationName

describe "010. XboxJS.Navigation.parseProtocolActivation", ->
	args = undefined
	beforeEach ->
		# Since we don't have the Xbox to parse the deepLink for us, 
		#  this is the closest I'm bothered getting in mirroring the
		args = detail:
		  kind: {}
		  uri:
		    host: ''
		    queryParsed: [
		    	{
		    		name: 'contentId',
		    		value: 'requiredValue'
		    	}
		    ]

	describe "should return appropriately for", ->
		it "default", ->
			args.detail.uri.host = 'default'
			expect(parse(args)).to.have.property('locationName', locationName.mediaHomeUri)
		it "media-details", ->
			args.detail.uri.host = 'media-details'
			expect(parse(args)).to.have.property('locationName', locationName.mediaDetailsUri)
		it "media-settings", ->
			args.detail.uri.host = 'media-settings'
			expect(parse(args)).to.have.property('locationName', locationName.mediaSettingsUri)
		it "media-help", ->
			args.detail.uri.host = 'media-help'
			expect(parse(args)).to.have.property('locationName', locationName.mediaHelpUri)
