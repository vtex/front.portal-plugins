# DEPENDENCIES:
# jQuery

$ = window.jQuery

# CLASSES
class Price
	constructor: (@element, @productId, @productData, @options) ->
		@sku = null

		@init()

	init: =>
		@bindEvents()
		@update()

	bindEvents: =>
		$(window).on 'vtex.sku.selected', @skuSelected
		$(window).on 'vtex.sku.unselected', @skuUnselected

	check: (productId) =>
		productId == @productId

	skuSelected: (evt, productId, sku) =>
		return unless check(productId)

	skuUnselected: (evt, productId, selectableSkus) =>
		return unless check(productId)



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
