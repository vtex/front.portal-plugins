defaultOptions = $.extend true, {}, $.fn.minicart.defaults
for element in this
	$element = $(element)
	domOptions = $element.data()
	options = $.extend(true, defaultOptions, domOptions, jsOptions)
	unless $element.data('minicart')
		$element.data('minicart', new Minicart($element, options))

return this