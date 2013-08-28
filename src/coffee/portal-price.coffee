# DEPENDENCIES:
# jQuery

$ = window.jQuery

# CLASSES
class Price
	constructor: (element, productId, productData, options) ->
		@element = element
		@productId = productId
		@productData = productData
		@options = options
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

	skuSelected: (evt, sku, productId) =>
		return unless check(productId)

	skuUnselected: (evt, selectableSkus, productId) =>
		return unless check(productId)



# PLUGIN ENTRY POINT
$.fn.price = (productId, productData, jsOptions) ->
	# Gather options
	domOptions = this.data()
	defaultOptions = $.fn.buyButton.defaults
	# Build final options object (priority: js, then dom, then default)
	# Deep extending with true, for the selectors
	options = $.extend(true, defaultOptions, domOptions, jsOptions)

	new Price(this, productId, productData, options)

	# Chaining
	return this


# PLUGIN DEFAULTS
$.fn.price.defaults =
	a: true
