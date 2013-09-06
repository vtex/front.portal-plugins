# DEPENDENCIES:
# jQuery
# Dust

$ = window.jQuery

# CLASSES
class NotifyMe extends ProductComponent
	constructor: (@context, @productId, @options) ->
		@init()
		@sku = null

	POST_URL: '/no-cache/AviseMe.aspx'

	init: =>
		@render()
		@bindEvents()

	render: =>
		dust.render 'notify-me', @options, (err, out) =>
			throw new Error("Notify Me Dust error: #{err}") if err
			@context.html out

	bindEvents: =>
		@bindProductEvent 'vtex.sku.selected', @skuSelected
		@bindProductEvent 'vtex.sku.unselected', @skuUnselected
		@context.on 'submit', @submit

	skuSelected: (evt, productId, sku) =>
		@sku = sku
		if sku.available
			@hideAll()
		else
			@showForm(sku.sku)

	skuUnselected: (evt, productId, skus) =>
		@sku = null
		@hideAll()
		
	submit: (evt) =>
		evt.preventDefault()

		@hideForm()
		@showLoading()

		xhr = $.post(@POST_URL, $(evt.target).serialize())
		.always(=> @hideLoading())
		.done(=> @showSuccess())
		.fail(=> @showError())

		@context.trigger 'vtex.notifyMe.submitted', [@productId, @sku, xhr]

		return false

	hideAll: =>
		@hideForm()
		@hideLoading()
		@hideSuccess()
		@hideError()

	findForm: => @context.find('form')
	hideForm: => @findForm().hide()
	showForm: (sku) =>
		@findForm().show().find('.notifyme-skuid').val(sku)

	findLoading: => @context.find('.notifyme-loading')
	hideLoading: => @findLoading().hide()
	showLoading: => @findLoading().show()

	findSuccess: => @context.find('.notifyme-success')
	hideSuccess: => @findSuccess().hide()
	showSuccess: => @findSuccess().show()

	findError: => @context.find('.notifyme-error')
	hideError: => @findError().hide()
	showError: => @findError().show()



# PLUGIN ENTRY POINT
$.fn.notifyMe = (productId, jsOptions) ->
	defaultOptions = $.extend {}, $.fn.notifyMe.defaults
	for element in this
		$element = $(element)
		domOptions = $element.data()
		options = $.extend(true, defaultOptions, domOptions, jsOptions)
		unless $element.data('notifyMe')
			$element.data('notifyMe', new NotifyMe($element, productId, options))

	return this


# PLUGIN DEFAULTS
$.fn.notifyMe.defaults =
	something: true
