# DEPENDENCIES:
# jQuery

$ = window.jQuery

# CLASSES
class Accessories
	constructor: (@element, @productId, @accessories, @options) ->



# PLUGIN ENTRY POINT
$.fn.accessories = (productId, accessories, jsOptions) ->
	defaultOptions = $.extend true, {}, $.fn.accessories.defaults
	for element in this
		$element = $(element)
		domOptions = $element.data()
		options = $.extend(true, defaultOptions, domOptions, jsOptions)
		unless $element.data('accessories')
			$element.data('accessories', new Accessories($element, productId, accessories, options))

	return this


# PLUGIN DEFAULTS
$.fn.accessories.defaults = {}
