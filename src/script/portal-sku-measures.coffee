# DEPENDENCIES:
# jQuery
# Dust

$ = window.jQuery

# CLASSES
class SkuMeasures extends ProductComponent
	constructor: (@element, @productId, @options) ->
		@sku = null

		@bindEvents()

	bindEvents: =>
		@bindProductEvent 'skuSelected.vtex', @skuSelected
		@bindProductEvent 'skuUnselected.vtex', @skuUnselected

	skuSelected: (evt, productId, sku) =>
		@sku = sku
		@render()

	skuUnselected: (evt, productId, selectableSkus) =>
		@sku = null
		@render()

	render: =>
		dust.render 'sku-measures',  @sku, (err, out) =>
			throw new Error "SkuMeasures Dust error: #{err}" if err
			@element.html out

# PLUGIN ENTRY POINT
$.fn.skuMeasures = (args, jsOptions) ->
	defaultOptions = $.extend {}, $.fn.skuMeasures.defaults
	for element in this
		$element = $(element)
		domOptions = $element.data()
		options = $.extend(true, defaultOptions, domOptions, jsOptions)
		unless $element.data('skuMeasures')
			$element.data('skuMeasures', new SkuMeasures($element, args, options))

	return this


# PLUGIN DEFAULTS
$.fn.skuMeasures.defaults =
	something: true
