# DEPENDENCIES:
# jQuery

$ = window.jQuery


# if we don't have underscore, make our own _.find
unless _.find
	_.find = (arr, iterator) ->
		for item in arr
			if !!iterator(item)
				return item

# CLASSES
class ShippingCalculator extends ProductComponent
	constructor: (@element, @productId, @options) ->
		@sku = null
		@quantity = 1

		@generateSelectors
			ShippingCalculatorButton: '.show-shipping-calculator'
			ShippingCalculatorForm: '#calculoFrete'
			CloseButton: '.bt-fechar'
			CalculateButton: '.freight-btn'
			PostalCodeInput: '.freight-zip-box'
			CalculationResult: '.freight-values'

		@SDK = CATALOG_SDK
		@SDK.getProductWithVariations(@productId).done (json) =>
			@productData = json
			if @productData.skus.length == 1
				@triggerProductEvent 'vtex.sku.selected', @productData.skus[0] #DEPRECATED
				@triggerProductEvent 'skuSelected.vtex', @productData.skus[0]

		@render()
		@bindEvents()

	bindEvents: =>
		@bindProductEvent 'skuSelected.vtex', @skuSelected
		@bindProductEvent 'skuUnselected.vtex', @skuUnselected
		@bindProductEvent 'skuSelectable.vtex', @skuUnselected
		@bindProductEvent 'quantityReady.vtex', @quantityChanged
		@bindProductEvent 'quantityChanged.vtex', @quantityChanged
		@findShippingCalculatorButton().on 'click', @showShippingCalculatorForm
		@findCloseButton().on 'click', @hideShippingCalculatorForm
		@findCalculateButton().on 'click', @calculateShipping

	render: =>
		dust.render 'shipping-calculator', @options, (err, out) =>
			throw new Error "Sku Selector Dust error: #{err}" if err
			@element.html out

	skuSelected: (evt, productId, sku) =>
		@sku = sku
		@updateVisibility()

	skuUnselected: (evt, productId, selectableSkus) =>
		@sku = _.find(selectableSkus, (sku) -> sku.available)
		@updateVisibility()

	updateVisibility: =>
		if @sku && @sku.available
			@element.show()
		else
			@element.hide()

	quantityChanged: (evt, productId, quantity) =>
		@quantity = quantity

	calculateShipping: =>
		postalCode = @findPostalCodeInput().val().replace(/[^A-Za-z0-9]/g, '')

		if postalCode == ''
			return alert(@options.strings.requiredPostalCode)

		@SDK.getShippingValue(@sku.sku, postalCode, @quantity or 1)
			.always (data) =>
				@findCalculationResult().html(data)

# PLUGIN ENTRY POINT
$.fn.shippingCalculator = (productId, jsOptions) ->
	defaultOptions = $.extend {}, $.fn.shippingCalculator.defaults
	for element in this
		$element = $(element)
		domOptions = $element.data()
		options = $.extend(true, defaultOptions, domOptions, jsOptions)
		unless $element.data('shippingCalculator')
			$element.data('shippingCalculator', new ShippingCalculator($element, productId, options))

	return this

# PLUGIN DEFAULTS
$.fn.shippingCalculator.defaults =
	showCorreiosSearch: true
	strings:
		calculateShipping: 'Calcule o valor do frete e prazo de entrega para a sua região:'
		enterPostalCode: 'Calcular o valor do frete e verificar disponibilidade:'
		requiredPostalCode: 'O CEP deve ser informado.'
		invalidPostalCode: 'CEP inválido.'
		requiredQuantity: 'É necessário informar a quantidade do mesmo Produto.'
		siteName: ''
		close: 'Fechar'

# COMPATIBILIDADE (DEPRECATED)
window.ShippingValue = ->
	$('.show-shipping-calculator').click()
