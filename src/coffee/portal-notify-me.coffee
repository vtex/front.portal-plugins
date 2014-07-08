# DEPENDENCIES:
# jQuery
# Dust

$ = window.jQuery

# CLASSES
class NotifyMe extends ProductComponent
	constructor: (@element, @productId, @options) ->
		@sku = @options.sku
		if CATALOG_SDK?
			@SDK = CATALOG_SDK
			if @productId?
				@SDK.getProductWithVariations(@productId).done (json) =>
					@productData = json
					if @productData.skus.length == 1
						@triggerProductEvent 'vtex.sku.selected', @productData.skus[0] #DEPRECATED
						@triggerProductEvent 'skuSelected.vtex', @productData.skus[0]
					@render()

		@generateSelectors
			Root: '.notifyme'
			TitleDiv: '.notifyme-title-div'
			Form: 'form'
			Name: '.notifyme-client-name'
			Email: '.notifyme-client-email'
			SkuId: '.notifyme-skuid'
			Loading: '.notifyme-loading-message'
			Success: 'fieldset.success'
			Error: 'fieldset.error'
			Button: '.notifyme-button-ok'

		@history = {}

		@init()

	POST_URL: '/no-cache/AviseMe.aspx'

	init: =>
		@render()
		@bindEvents()

	render: =>
		unless @productData and @productData.displayMode == 'lista'
			dust.render 'notify-me', @options, (err, out) =>
				throw new Error("Notify Me Dust error: #{err}") if err
				@element.html out
				@showNM() if @options.sku

	bindEvents: =>
		unless @options.sku
			@bindProductEvent 'skuSelected.vtex', @skuSelected
			@bindProductEvent 'skuUnselected.vtex', @skuUnselected
		@element.on 'submit', @submit if @options.ajax
		@findButton().on 'click', @submit if @options.ajax

	skuSelected: (evt, productId, sku) =>
		@sku = sku.sku
		@hideAll()
		if @options.sku or not sku.available
			@showNM()

	showNM: =>
		@showRoot()
		@showTitleDiv()
		switch @history[@sku]
			when 'success' then @showSuccess()
			else
				@findSkuId().val(@sku)
				@showForm()
				@showName()
				@showEmail()
				@showButton()

	skuUnselected: (evt, productId, skus) =>
		@sku = null
		@hideAll()

	setError: (message) =>
		@findError().find('span').text(message)
		
	submit: (evt) =>
		evt.preventDefault()

		$name = @findName()
		if $name.val() is ''
			$name.focus()
			return false

		$email = @findEmail()
		if $email.val() is ''
			$email.focus()
			return false
		if not $email.val().match(/^.+@.+\..+$/)
			$email.focus()
			@setError(@options.strings.emailErrorMessage)
			@showError()
			return false

		@hideForm()
		@hideError()
		@showLoading()

		xhr = $.post(@POST_URL, @findForm().serialize())
		.always =>
			@hideLoading()
		.done =>
			@showSuccess()
			@history[@sku] = 'success'
		.fail =>
			@showForm()
			@setError(@options.strings.error)
			@showError()
			@history[@sku] = 'fail'

		@triggerProductEvent 'vtex.notifyMe.submitted', @sku, xhr #DEPRECATED
		@triggerProductEvent 'notifyMeSubmitted.vtex', @sku, xhr

		return false

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
	sku: null
	strings:
		title: ''
		explanation: 'Para ser avisado da disponibilidade deste Produto, basta preencher os campos abaixo.'
		namePlaceholder: 'Digite seu nome...'
		emailPlaceholder: 'Digite seu e-mail...'
		loading: 'Carregando...'
		success: 'Cadastrado com sucesso. Assim que o produto for disponibilizado você receberá um email avisando.'
		error: 'Não foi possível cadastrar. Tente mais tarde.'
		emailErrorMessage: 'Email inválido, digite novamente.'