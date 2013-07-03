jasmine.getFixtures().fixturesPath = "base/build/"

describe 'SkuSelector', ->
	it 'should exist', ->
		expect(vtex.portalPlugins.SkuSelector).toBeDefined()

describe '$.skuSelector', ->

	beforeEach ->
		loadFixtures 'templates/sku-selector.html'

	it 'should have jQuery', ->
		expect($).toBeDefined()
	it 'should exist', ->
		expect($.fn.skuSelector).toBeDefined()
		expect($.skuSelector).toBeDefined()

	it 'should have loaded fixtures correctly', ->
		console.log $('div').length

		expect($('.sku-selector-container')).toExist()