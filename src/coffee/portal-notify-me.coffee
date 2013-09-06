# DEPENDENCIES:
# jQuery
# Dust

$ = window.jQuery

# CLASSES
class NotifyMe
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
		$(window).on 'vtex.sku.selected', @skuSelected
		$(window).on 'vtex.sku.unselected', @skuUnselected
		@context.on 'submit', @submit if @options.ajax

	check: (productId) =>
		productId == @productId

	skuSelected: (evt, productId, sku) =>
		return unless @check(productId)
		@sku = sku
		if sku.available
			@hideAll()
		else
			@showTitle()
			@showForm(sku.sku)

	skuUnselected: (evt, productId, skus) =>
		return unless @check(productId)
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
		@hideTitle()
		@hideForm()
		@hideLoading()
		@hideSuccess()
		@hideError()

	findTitle: => @context.find('.notifyme-title')
	hideTitle: => @findTitle().hide()
	showTitle: => @findTitle().show()

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
	ajax: true
	strings:
		title: ''
		explanation: 'Para ser avisado da disponibilidade deste Produto, basta preencher os campos abaixo.'
		namePlaceholder: 'Digite seu nome...'
		emailPlaceholder: 'Digite seu e-mail...'
		loading: 'Carregando...'
		success: 'Cadastrado com sucesso. Assim que o produto for disponibilizado você receberá um email avisando.'
		error: 'Não foi possível cadastrar. Tente mais tarde.'
