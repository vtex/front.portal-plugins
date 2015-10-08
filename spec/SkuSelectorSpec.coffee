#jasmine.getFixtures().fixturesPath = "base/build"
#jasmine.getJSONFixtures().fixturesPath = "base/build/spec/mocks"
#
#
#describe 'SkuSelector Plugin', ->
#	beforeEach ->
#		mockNames = ['oneDimensionAvailable.json', 'threeDimensionsAvailable.json', 'threeDimensionsSomeUnavailable.json']
#		loadJSONFixtures(mockNames...)
#		@mocks = (getJSONFixture(name) for name in mockNames)
#
#	it 'should have loaded JSON fixtures correctly', ->
#		#Assert
#		expect(typeof @mocks).toBe(typeof [])
#		expect(@mocks[0]).toBeDefined()
#		expect(typeof @mocks[0]).toBe(typeof {})
#
#	describe 'SkuSelector Class', ->
#		beforeEach ->
#			@mock = @mocks[2]
#			@ss = new vtex.portalPlugins.SkuSelector(@mock)
#
#		it 'should exist', ->
#			#Assert
#			expect(vtex.portalPlugins.SkuSelector).toBeDefined()
#
#		it 'should be instantiated', ->
#			#Assert
#			expect(@ss instanceof vtex.portalPlugins.SkuSelector).toBe(true)
#
#		describe 'constructor', ->
#			it 'should import productId', ->
#				#Assert
#				expect(@ss.productId).toEqual(@mock.productId)
#
#			it 'should import product name', ->
#				#Assert
#				expect(@ss.name).toEqual(@mock.name)
#
#			it 'should import all dimensions', ->
#				#Assert
#				expect(@ss.dimensions.length).toEqual(@mock.dimensions.length)
#
#			it 'should import dimension names', ->
#				#Assert
#				expect((dim.name for dim in @ss.dimensions)).toEqual(@mock.dimensions)
#
#			it 'should initialize', ->
#				#Assert
#				expect(dim.selected).toBeUndefined() for dim in @ss.dimensions
#
#			it "should import each dimension's values", ->
#				#Assert
#				expect(dim.values).toEqual(@mock.dimensionsMap[dim.name]) for dim in @ss.dimensions
#
#			it "should import each dimension's input types", ->
#				#Assert
#				expect(dim.inputType).toEqual(@mock.dimensionsInputType[dim.name] or "radio") for dim in @ss.dimensions
#
#			it 'should import skus', ->
#				#Assert
#				expect(@ss.skus).toEqual(@mock.skus)
#
#		it "should select a sku by setting each dimension's selected to its values", ->
#			#Arrange
#			sku = @mock.skus[0]
#
#			#Act
#			@ss.selectSku(sku)
#
#			#Assert
#			expect(dim.selected).toEqual(sku.dimensions[dim.name]) for dim in @ss.dimensions
#
#		it 'should search the dimensions using the given function', ->
#			#Arrange
#			fn = -> true
#			spyOn($, 'grep').andCallThrough()
#
#			#Act
#			searchResults = @ss.searchDimensions(fn)
#
#			#Assert
#			expect(searchResults).toEqual(@ss.dimensions)
#			expect($.grep).toHaveBeenCalledWith(@ss.dimensions, fn)
#
#		it 'should get the dimension by its name', ->
#			#Arrange
#			dimension = @ss.dimensions[0]
#			name = dimension.name
#
#			#Act
#			result = @ss.getDimensionByName(name)
#
#			#Assert
#			expect(result).toEqual(dimension)
#
#		it 'should get and set selected dimension', ->
#			#Arrange
#			dim  = @ss.dimensions[0]
#			value = "12kg"
#
#			#Act
#			@ss.setSelectedDimension(dim.name, value)
#			result = @ss.getSelectedDimension(dim.name)
#
#			#Assert
#			expect(result).toEqual(value)
#
#
#	describe 'SkuSelectorRenderer', ->
#		beforeEach ->
#			@ssr = new vtex.portalPlugins.SkuSelectorRenderer($('html'), {}, {})
#
#		it 'should exist', ->
#			#Assert
#			expect(vtex.portalPlugins.SkuSelectorRenderer).toBeDefined()
#
#		it 'should be instantiated', ->
#			#Assert
#			expect(@ssr instanceof vtex.portalPlugins.SkuSelectorRenderer).toBe(true)
#
#
#	describe '$.skuSelector', ->
#		beforeEach ->
#			loadFixtures 'sku-selector.html'
#
#		it 'should have jQuery', ->
#			#Assert
#			expect($).toBeDefined()
#
#		it 'should exist', ->
#			#Assert
#			expect($.fn.skuSelector).toBeDefined()
#			expect($.skuSelector).toBeDefined()
#
#		it 'should have loaded HTML fixtures correctly', ->
#			#Assert
#			expect($('.sku-selector-container')).toExist()
#
#		it 'should return a jQuery object, for chaining', ->
#			#Arrange
#			element = $('.sku-selector-container')
#
#			#Act
#			result = element.skuSelector(@mocks[0])
#
#			#Assert
#			expect(result).toBe(element)
#
