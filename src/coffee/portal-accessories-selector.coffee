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
	constructor: (@element, @productId, @accessoriesData, @options) ->
		@init()

	init: =>
		@render()

	render: =>
		dust.render 'accessories-selector', @accessoriesData, (err, out) =>
			throw new Error "Accessories Selector Dust error: #{err}" if err
			@element.html out
			@bindEvents()

	bindEvents: =>
		@element.find('.accessory-checkbox').on 'change', @accessorySelected

	accessorySelected: (evt) =>
		$element = $(evt.target)

		acc = quantity: if $element.attr('checked') then 1 else 0
		$.extend acc, @accessoriesData.accessories[$element.data('accIndex')]

		$element.trigger 'vtex.accessory.selected', [@productId, acc]

# PLUGIN ENTRY POINT
$.fn.accessoriesSelector = (productId, accessoriesData, jsOptions) ->
	defaultOptions = $.extend true, {}, $.fn.accessoriesSelector.defaults
	for element in this
		$element = $(element)
		domOptions = $element.data()
		options = $.extend(true, defaultOptions, domOptions, jsOptions)
		unless $element.data('accessoriesSelector')
			$element.data('accessoriesSelector', new AccessoriesSelector($element, productId, accessoriesData, options))

	return this


# PLUGIN DEFAULTS
$.fn.accessoriesSelector.defaults = {}
