jasmine.getFixtures().fixturesPath = "base/spec/fixtures"
jasmine.getJSONFixtures().fixturesPath = "base/src/mocks"

describe 'SkuSelector Plugin', ->
	beforeEach ->
		mockNames = ['1.json', '2.json']
		loadJSONFixtures(mockNames...)
		@mocks = (getJSONFixture(name) for name in mockNames)
		loadFixtures 'sku-selector.html'
		jasmine.Ajax.install()

	afterEach ->
		jasmine.Ajax.uninstall()

	it 'should have loaded JSON fixtures correctly', ->
		#Assert
		expect(typeof @mocks).toBe(typeof [])
		expect(@mocks[0]).toBeDefined()
		expect(typeof @mocks[0]).toBe(typeof {})

	describe '$.skuSelector', ->
		it 'should have jQuery', ->
			#Assert
			expect($).toBeDefined()

		it 'should exist', ->
			#Assert
			expect($.fn.skuSelector).toBeDefined()

		it 'should have loaded HTML fixtures correctly', ->
			#Assert
			expect($('.portal-sku-selector-ref')).toExist()

		it 'should return a jQuery object, for chaining', ->
			#Arrange
			element = $('.portal-sku-selector-ref')

			#Act
			result = element.skuSelector(@mocks[0])

			#Assert
			expect(result).toBe(element)
