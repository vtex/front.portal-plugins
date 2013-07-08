jasmine.getFixtures().fixturesPath = "base/build/spec/fixtures"
jasmine.getJSONFixtures().fixturesPath = "base/build/spec/mocks"


describe 'SkuSelector Plugin', ->
	beforeEach ->
		mockNames = ['oneDimensionAvailable.json', 'threeDimensionsAvailable.json', 'threeDimensionsSomeUnavailable.json']
		loadJSONFixtures(mockNames...)
		@mocks = (getJSONFixture(name) for name in mockNames)

	it 'should have loaded JSON fixtures correctly', ->
		expect(@mocks[0]).toBeDefined()
		expect(typeof @mocks[0]).toBe(typeof {})

	describe 'SkuSelector Class', ->
		beforeEach ->
			@mock = @mocks[2]
			@ss = new vtex.portalPlugins.SkuSelector(@mock)

		it 'should exist', ->
			expect(vtex.portalPlugins.SkuSelector).toBeDefined()
		it 'should be instantiated', ->
			expect(@ss instanceof vtex.portalPlugins.SkuSelector).toBe(true)

		it 'should import productId', ->
			expect(@ss.productId).toEqual(@mock.productId)
		it 'should import name', ->
			expect(@ss.name).toEqual(@mock.name)
		it 'should import dimensions', ->
			# Number of dimensions
			expect(@ss.dimensions.length).toEqual(@mock.dimensions.length)
			# Dimension names
			expect((dim.name for dim in @ss.dimensions)).toEqual(@mock.dimensions)
			# Dimension selected map
			expect(dim.selected).toBeUndefined() for dim in @ss.dimensions
			# Dimension values
			expect(dim.values).toEqual(@mock.dimensionsMap[dim.name]) for dim in @ss.dimensions
		it 'should import skus', ->
			expect(@ss.skus).toEqual(@mock.skus)

		it 'should find undefined dimensions', ->
			undefinedDimensions = (dim for dim in @ss.dimensions when dim.selected is undefined)
			expect(@ss.findUndefinedDimensions()).toEqual(undefinedDimensions)

		it 'should find available skus', ->
			availableSkus = (sku for sku in @ss.skus when sku.available is true)
			expect(@ss.findAvailableSkus()).toEqual(availableSkus)

		#TODO it 'should assert that a sku is selectable', ->

		#TODO it 'should find the selectable skus', ->


		it 'should search the dimensions using the given function', ->
			fn = ()->true
			spyOn($, 'grep').andCallThrough()
			expect(@ss.searchDimensions(fn)).toEqual(@ss.dimensions)
			expect($.grep).toHaveBeenCalledWith(@ss.dimensions, fn)

		#TODO it 'should search the dimensions correctly', ->

		it 'should get the dimension by its name', ->
			expect(@ss.getDimensionByName(@ss.dimensions[0].name)).toEqual(@ss.dimensions[0])

		describe 'findSelectedSku', ->
			it 'should find when it is unique', ->
				spyOn(@ss, 'findSelectableSkus').andReturn([@mock.skus[0]])
				expect(@ss.findSelectedSku()).toEqual(@mock.skus[0])

			it 'should not find when it is not unique', ->
				spyOn(@ss, 'findSelectableSkus').andReturn([@mock.skus[0], @mock.skus[1]])
				expect(@ss.findSelectedSku()).toBeUndefined()

			it 'should not find when it is empty', ->
				spyOn(@ss, 'findSelectableSkus').andReturn([])
				expect(@ss.findSelectedSku()).toBeUndefined()


		it 'should get and set selected dimension', ->
			dim  = @ss.dimensions[0]
			@ss.setSelectedDimension(dim.name, "12kg")
			expect(@ss.getSelectedDimension(dim.name)).toEqual("12kg")

		it 'should reset the next dimensions', ->
			@ss.resetNextDimensions(@ss.dimensions[0].name)
			expect(@ss.getSelectedDimension(dim.name)).toBeUndefined() for dim, i in @ss.dimensions when i > 0


	describe 'SkuSelectorRenderer', ->
		beforeEach ->
			@ssr = new vtex.portalPlugins.SkuSelectorRenderer()

		it 'should exist', ->
			expect(vtex.portalPlugins.SkuSelectorRenderer).toBeDefined()
		it 'should be instantiated', ->
			expect(@ssr instanceof vtex.portalPlugins.SkuSelectorRenderer).toBe(true)

		it 'should call updatePriceAvailable', ->
			sku = {available: true}
			spyOn(@ssr, 'updatePriceAvailable')
			@ssr.updatePrice(sku)

			expect(@ssr.updatePriceAvailable).toHaveBeenCalledWith(sku)

		it 'should call updatePriceUnavailable', ->
			sku = {available: false}
			spyOn(@ssr, 'updatePriceUnavailable')
			@ssr.updatePrice(sku)

			expect(@ssr.updatePriceUnavailable).toHaveBeenCalled()


	describe '$.skuSelector', ->
		beforeEach ->
			loadFixtures 'sku-selector.html'

		it 'should have jQuery', ->
			expect($).toBeDefined()
		it 'should exist', ->
			expect($.fn.skuSelector).toBeDefined()
			expect($.skuSelector).toBeDefined()

		it 'should have loaded HTML fixtures correctly', ->
			expect($('.sku-selector-container')).toExist()

		it 'should return jQuery object, for chaining', ->
			$el = $('.sku-selector-container')
			expect($el.skuSelector(@mocks[0])).toBe($el)

