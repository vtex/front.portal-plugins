# DEPENDENCIES:
# jQuery

$ = window.jQuery

# CLASSES
class AccessoriesSelector
	constructor: (@element, @productId, @accessories, @options) ->



# PLUGIN ENTRY POINT
$.fn.accessoriesSelector = (productId, accessories, jsOptions) ->
	defaultOptions = $.extend true, {}, $.fn.accessoriesSelector.defaults
	for element in this
		$element = $(element)
		domOptions = $element.data()
		options = $.extend(true, defaultOptions, domOptions, jsOptions)
		unless $element.data('accessoriesSelector')
			$element.data('accessoriesSelector', new AccessoriesSelector($element, productId, accessories, options))

	return this


# PLUGIN DEFAULTS
$.fn.accessoriesSelector.defaults = {}
