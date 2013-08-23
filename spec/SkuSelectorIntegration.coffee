jasmine.getFixtures().fixturesPath = "base/spec/fixtures"
jasmine.getJSONFixtures().fixturesPath = "base/spec/mocks"

describe 'Sku Selector Integration', ->
	beforeEach ->
		mockNames = ['oneDimensionAvailable.json', 'threeDimensionsAvailable.json', 'threeDimensionsSomeUnavailable.json']
		loadJSONFixtures(mockNames...)
		@mocks = (getJSONFixture(name) for name in mockNames)
		@mock = @mocks[0]
		loadFixtures 'sku-selector.html'

	it 'should have loaded JSON fixtures correctly', ->
		#Assert
		expect(typeof @mocks).toBe(typeof [])
		expect(typeof @mock).toBe(typeof {})

	it 'should exist', ->
		#Assert
		expect($.fn.skuSelector).toBeDefined()
		expect($.skuSelector).toBeDefined()

	it 'should have loaded HTML fixtures correctly', ->
		#Assert
		expect($('.sku-selector-ref')).toExist()

	describe '$', ->
		beforeEach ->
			$('.sku-selector-ref').skuSelector(@mock)