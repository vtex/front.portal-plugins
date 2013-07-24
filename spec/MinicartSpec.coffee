jasmine.getFixtures().fixturesPath = "base/build"
jasmine.getJSONFixtures().fixturesPath = "base/build/spec/mocks"


describe 'Minicart Plugin', ->
	beforeEach ->
		mockNames = ['orderform.json']
		loadJSONFixtures(mockNames...)
		@mocks = (getJSONFixture(name) for name in mockNames)

	it 'should have loaded JSON fixtures correctly', ->
		#Assert
		expect(typeof @mocks).toBe(typeof [])
		expect(@mocks[0]).toBeDefined()
		expect(typeof @mocks[0]).toBe(typeof {})


	describe '$.minicart', ->
		beforeEach ->
			loadFixtures 'minicart.html'

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

		it 'should add a class', ->
			#Arrange
			element = $('.portal-minicart-ref')

			#Act
			element.minicart()

			#Assert
			expect(element.hasClass('plugin_minicart')).toBe(true)