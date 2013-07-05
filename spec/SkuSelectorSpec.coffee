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
			expect(@ss.dimensions).toEqual(@mock.dimensions)
		it 'should import skus', ->
			expect(@ss.skus).toEqual(@mock.skus)
		it 'should import dimensionsMap', ->
			expect(@ss.uniqueDimensionsMap).toEqual(@mock.dimensionsMap)

		it 'should find undefined dimensions', ->
			undefinedDimensions = (key for key, value of @ss.selectedDimensionsMap when value is undefined)
			expect(@ss.findUndefinedDimensions()).toEqual(undefinedDimensions)

		it 'should find available skus', ->
			availableSkus = (sku for sku in @ss.skus when sku.available is true)
			expect(@ss.findAvailableSkus()).toEqual(availableSkus)

		it 'should find the selectable skus'

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


		describe 'selectedDimensionsMap', ->
			it 'should initially be filled with undefined', ->
				for selectedDimension in @ss.selectedDimensionsMap
					expect(selectedDimension).toBeUndefined()

			it 'should have the same length as dimensions', ->
				expect(Object.keys(@ss.selectedDimensionsMap).length).toEqual(@ss.dimensions.length)

			it 'should get and set', ->
				dim  = @ss.dimensions[0]
				@ss.setSelectedDimension(dim, "12kg")
				expect(@ss.getSelectedDimension(dim)).toEqual("12kg")



	describe 'SkuSelectorRenderer', ->
		beforeEach ->
			@ssr = new vtex.portalPlugins.SkuSelectorRenderer()

		it 'should exist', ->
			expect(vtex.portalPlugins.SkuSelectorRenderer).toBeDefined()
		it 'should be instantiated', ->
			expect(@ssr instanceof vtex.portalPlugins.SkuSelectorRenderer).toBe(true)

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



