# DEPENDENCIES:
# jQuery

$ = window.jQuery

# CLASSES
class Price extends ProductComponent
	constructor: (@element, @productId, @productData, @options) ->
		@sku = null

		@init()

	init: =>
		@bindEvents()
		@update()

	bindEvents: =>
		@getProductEvent 'vtex.sku.selected', @skuSelected
		@getProductEvent 'vtex.sku.unselected', @skuUnselected

	skuSelected: (evt, productId, sku) =>

	skuUnselected: (evt, productId, selectableSkus) =>

# PLUGIN ENTRY POINT
$.fn.price = (productId, productData, jsOptions) ->
	defaultOptions = $.extend {}, $.fn.price.defaults
	for element in this
		$element = $(element)
		domOptions = $element.data()
		options = $.extend(true, defaultOptions, domOptions, jsOptions)
		unless $element.data('price')
			$element.data('price', new Price($element, productId, productData, options))

	return this


# PLUGIN DEFAULTS
$.fn.price.defaults = {}
