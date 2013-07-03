jasmine.getFixtures().fixturesPath = "base/build/"

describe 'SkuSelector', ->

	it 'should have jQuery', ->
		expect($).toBeDefined()
	it 'should exist', ->
		expect($.fn.skuSelector).toBeDefined()
		expect($.skuSelector).toBeDefined()


	describe 'Popup', ->
		beforeEach ->
			loadFixtures 'popup.html'

		it 'should have loaded fixtures correctly', ->
			expect($('div')).toExist()

	describe 'Product', ->
		beforeEach ->
			loadFixtures 'product.html'

		it 'should have loaded fixtures correctly', ->
			expect($('div')).toExist()