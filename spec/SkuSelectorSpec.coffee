jasmine.getFixtures().fixturesPath = "base/build/spec/fixtures"
jasmine.getJSONFixtures().fixturesPath = "base/build/spec/mocks"

describe 'SkuSelector', ->
	it 'should exist', ->
		expect(vtex.portalPlugins.SkuSelector).toBeDefined()

describe '$.skuSelector', ->

	beforeEach ->
		loadFixtures 'sku-selector.html'
		loadJSONFixtures('oneDimensionAvailable.json', 'threeDimensionsAvailable.json', 'threeDimensionsSomeUnavailable.json')

	it 'should have jQuery', ->
		expect($).toBeDefined()
	it 'should exist', ->
		expect($.fn.skuSelector).toBeDefined()
		expect($.skuSelector).toBeDefined()

	it 'should have loaded HTML fixtures correctly', ->
		expect($('.sku-selector-container')).toExist()

	it 'should have loaded JSON fixtures correctly', ->
		mock1 = getJSONFixture('oneDimensionAvailable.json')
		expect(mock1).toBeDefined()
		expect(typeof mock1).toBe(typeof {})

