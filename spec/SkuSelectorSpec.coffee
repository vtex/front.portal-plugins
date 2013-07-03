jasmine.getFixtures().fixturesPath = "base/build/"

describe 'SkuSelector', ->

	it 'should have jQuery', ->
		expect($).toBeDefined()
	it 'should exist', ->
		expect($.fn.skuSelector).toBeDefined()
		expect($.skuSelector).toBeDefined()

	beforeEach ->
		loadFixtures 'sku-selector.html'

	it 'should have loaded fixtures correctly', ->
		expect($('div')).toExist()