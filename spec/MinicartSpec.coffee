#jasmine.getFixtures().fixturesPath = "base/build"
#jasmine.getJSONFixtures().fixturesPath = "base/build/spec/mocks"
#
#
#describe 'Minicart Plugin', ->
#	beforeEach ->
#		mockNames = ['orderform.json']
#		loadJSONFixtures(mockNames...)
#		@mocks = (getJSONFixture(name) for name in mockNames)
#		loadFixtures 'minicart.html'
#		jasmine.Ajax.useMock()
#
#
#	it 'should have loaded JSON fixtures correctly', ->
#		#Assert
#		expect(typeof @mocks).toBe(typeof [])
#		expect(@mocks[0]).toBeDefined()
#		expect(typeof @mocks[0]).toBe(typeof {})
#
#	describe 'Minicart Class', ->
#		beforeEach ->
#			@element = $('.portal-minicart-ref')
#			@minicart = new vtex.portalPlugins.Minicart(@element, {})
#
#		it 'should import the context', ->
#			#Assert
#			expect(@minicart.context).toEqual(@element)
#
#		it 'should have a hover context', ->
#			#Assert
#			expect(@minicart.hoverContext).toBeDefined()
#
#		it 'should POST to update data', ->
#			#Act
#			@minicart.updateData()
#			request = mostRecentAjaxRequest()
#
#			#Assert
#			expect(request.url).toBe(@minicart.getOrderFormURL())
#			expect(request.method).toBe("POST")
#
#		it 'should update values and items when updating the cart', ->
#			#Arrange
#			valuesSpy = spyOn(@minicart, 'updateValues')
#			itemsSpy = spyOn(@minicart, 'updateItems')
#
#			#Act
#			@minicart.updateCart()
#
#			#Assert
#			expect(valuesSpy).toHaveBeenCalled()
#			expect(itemsSpy).toHaveBeenCalled()
#
#		it 'should have binded events', ->
#			#Assert
#			expect(@minicart.hoverContext).toHandle('mouseover')
#			expect(@minicart.hoverContext).toHandle('mouseout')
#			expect($(window)).toHandle('minicartMouseOver')
#			expect($(window)).toHandle('minicartMouseOut')
#			expect($(window)).toHandle('cartUpdated')
#			expect($(window)).toHandle('productAddedToCart')
#
#
#
#	describe '$.minicart', ->
#		it 'should have jQuery', ->
#			#Assert
#			expect($).toBeDefined()
#
#		it 'should exist', ->
#			#Assert
#			expect($.fn.minicart).toBeDefined()
#
#		it 'should have some defaults', ->
#			#Assert
#			expect($.fn.minicart.defaults).toBeDefined()
#
#		it 'should have loaded HTML fixtures correctly', ->
#			#Assert
#			expect($('.portal-minicart-ref')).toExist()
#
#		it 'should return a jQuery object, for chaining', ->
#			#Arrange
#			element = $('.portal-minicart-ref')
#
#			#Act
#			result = element.minicart()
#
#			#Assert
#			expect(result).toBe(element)
#
#		it 'should add a class', ->
#			#Arrange
#			element = $('.portal-minicart-ref')
#
#			#Act
#			element.minicart()
#
#			#Assert
#			expect(element.hasClass('plugin_minicart')).toBe(true)
#
##		it 'should not be initialized twice', ->
##			#Arrange
##			element = $('.portal-minicart-ref')
##			spy = spyOn(vtex.portalPlugins, 'Minicart')
##
##			#Act
##			element.minicart()
##
##			#Assert
##			expect(spy.calls.length).toBe(1)