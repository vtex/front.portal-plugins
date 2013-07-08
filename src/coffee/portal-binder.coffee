$('.to-bind').each () ->
	$el = $(@)
	fn = eval($el.data('toBind'))
	$el.on 'click', fn
	$el.removeClass('to-bind')