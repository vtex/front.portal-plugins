# DEPENDENCIES:
# jQuery

$ = window.jQuery

# CLASSES
class NotifyMe
	constructor: (@context, args, @options) ->
		#

# PLUGIN ENTRY POINT
$.fn.notifyMe = (args, jsOptions) ->
	defaultOptions = $.extend {}, $.fn.notifyMe.defaults
	for element in this
		$element = $(element)
		domOptions = $element.data()
		options = $.extend(true, defaultOptions, domOptions, jsOptions)
		unless $element.data('notifyMe')
			$element.data('notifyMe', new NotifyMe($element, args, options))

	return this


# PLUGIN DEFAULTS
$.fn.notifyMe.defaults =
	something: true
