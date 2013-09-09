# DEPENDENCIES:
# jQuery
# vtex-utils
# Dust

$ = window.jQuery

# DUST FILTERS
_.extend dust.filters,
	intAsCurrency: (value) -> _.intAsCurrency value

# CLASSES
class AccessoriesSelector
	constructor: (@element, @productId, @productData, @options) ->
		@accessories = []

		for accessory in @productData.accessories
			productCopy = $.extend true, {}, accessory
			delete productCopy.skus
			for sku in accessory.skus
				skuCopy = $.extend quantity: 0, sku
				@accessories.push($.extend {}, productCopy, skuCopy)

		@init()

	init: =>
		@render()

	render: =>
		dust.render 'accessories-selector', accessories: @accessories, (err, out) =>
			throw new Error "Accessories Selector Dust error: #{err}" if err
			@element.html out
			@bindEvents()

	bindEvents: =>
		@element.find('.accessory-checkbox').on 'change', @accessorySelected

	accessorySelected: (evt) =>
		$element = $(evt.target)

		index = $element.data('accessory-index')
		accessory = @accessories[index]
		accessory.quantity = if $element.attr('checked') then 1 else 0

		$element.trigger 'vtex.accessories.updated', [@productId, @accessories]

# PLUGIN ENTRY POINT
$.fn.accessoriesSelector = (productId, productData, jsOptions) ->
	defaultOptions = $.extend true, {}, $.fn.accessoriesSelector.defaults
	for element in this
		$element = $(element)
		domOptions = $element.data()
		options = $.extend(true, defaultOptions, domOptions, jsOptions)
		unless $element.data('accessoriesSelector')
			$element.data('accessoriesSelector', new AccessoriesSelector($element, productId, productData, options))

	return this


# PLUGIN DEFAULTS
$.fn.accessoriesSelector.defaults = {}
