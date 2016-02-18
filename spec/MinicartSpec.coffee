jasmine.getFixtures().fixturesPath = "base/spec/fixtures"
jasmine.getJSONFixtures().fixturesPath = "base/src/mocks"

describe 'Minicart Plugin', ->
	beforeEach ->
		mockNames = ['orderform.json']
		loadJSONFixtures('orderform.json')
		@mocks = (getJSONFixture(name) for name in mockNames)
		loadFixtures 'mini-cart.html'
		jasmine.Ajax.install()

	afterEach ->
		jasmine.Ajax.uninstall()

	it 'should have loaded JSON fixtures correctly', ->
		#Assert
		expect(@mocks.length).toBe(1)

	describe '$.minicart', ->
		it 'should have jQuery', ->
			#Assert
			expect($).toBeDefined()

		it 'should exist', ->
			#Assert
			expect($.fn.minicart).toBeDefined()

		it 'should have some defaults', ->
			#Assert
			expect($.fn.minicart.defaults).toBeDefined()

		it 'should have loaded HTML fixtures correctly', ->
			#Assert
			expect($('.portal-minicart-ref')).toExist()

		it 'should return a jQuery object, for chaining', ->
			#Arrange
			element = $('.portal-minicart-ref')

			#Act
			result = element.minicart()

			#Assert
			expect(result).toBe(element)
