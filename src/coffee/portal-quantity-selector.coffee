# DEPENDENCIES:
# jQuery

$ = window.jQuery

roundPlaces = (num, places) ->
	Math.round(num * Math.pow(10, places)) / Math.pow(10, places)

# CLASS
class QuantitySelector extends ProductComponent
	constructor: (@element, @productId, @options) ->

		@unitVariations = {}
		for v in @options.unitVariations
			@unitVariations["#{v.skuId}"] =
				measurementUnit: v.measurementUnit
				unitMultiplier: v.unitMultiplier

		@sku = null
		@unitMultiplier = @unitVariations[@options.unitVariations[0]?.skuId]?.unitMultiplier or 1
		@measurementUnit = @unitVariations[@options.unitVariations[0]?.skuId]?.measurementUnit or 'un.'

		@units = @options.initialQuantity * @unitMultiplier
		@quantity = @options.initialQuantity

		@generateSelectors
			UnitSelectorInput: '.unitSelector input'
			QuantitySelectorInput: '.quantitySelector input'
			MeasurementUnit: '.measurementUnit'

		@init()

	unitMax: =>
		@unitMultiplier * @options.max

	unitMin: =>
		@unitMultiplier * @options.min

	init: =>
		@render()
		@bindEvents()
		@triggerProductEvent 'vtex.quantity.ready', @quantity #DEPRECATED
		@triggerProductEvent 'quantityReady.vtex', @quantity
		@triggerProductEvent 'vtex.quantity.changed', @quantity #DEPRECATED
		@triggerProductEvent 'quantityChanged.vtex', @quantity #DEPRECATED

	render: =>
		renderData =
			unitBased: @options.unitBased
			units: @units
			unitMin: @unitMultiplier * @options.min
			unitMax: @unitMultiplier * @options.max
			measurementUnit: @measurementUnit
			max: @options.max
			quantity: @quantity

		dust.render "quantity-selector", renderData, (err, out) =>
			throw new Error "Quantity Selector Dust error: #{err}" if err
			@element.html out

	bindEvents: =>
		@bindProductEvent 'skuSelected.vtex', @skuSelected
		@bindProductEvent 'quantityChanged.vtex', @quantityChanged
		@findUnitSelectorInput().on 'keypress', @handleUnitsKeypress
		@findUnitSelectorInput().on 'change', @unitInputChanged
		@findQuantitySelectorInput().on 'keypress', @handleQuantityKeypress
		@findQuantitySelectorInput().on 'change', @quantityInputChanged

	update: =>
		@findUnitSelectorInput().val(@units).attr('max', @units * @options.max)
		@findQuantitySelectorInput().val(@quantity)
		@findMeasurementUnit().text(@measurementUnit)

	skuSelected: (evt, productId, sku) =>
		@sku = sku.sku

		if @options.unitBased
			@measurementUnit = @unitVariations[@sku].measurementUnit
			@unitMultiplier = @unitVariations[@sku].unitMultiplier
			@updateUnitsFromQuantity()

		@update()

	quantityChanged: (evt, productId, quantity) =>
		@quantity = quantity
		@updateQuantityFromUnits()
		@update()

	updateQuantityFromUnits: =>
		@quantity = Math.ceil(@units/@unitMultiplier)

	unitInputChanged: (evt) =>
		$element = $(evt.target)
		@units = $element.val()
		@cleanUnits()
		@updateQuantityFromUnits()
		@update()
		@triggerProductEvent 'vtex.quantity.changed', @quantity #DEPRECATED
		@triggerProductEvent 'quantityChanged.vtex', @quantity

	cleanUnits: =>
		@units = @units.replace(/,/, '.').replace(/[^0-9\.]+/g, '')
		@units = roundPlaces(@units, @options.decimalPlaces)
		if @units > @unitMax()
			@units = @unitMax()
			alert("Por favor, escolha uma quantidade menor que #{@unitMax()}.")
		else if @units < @unitMin()
			@units = @unitMin()

	handleUnitsKeypress: (evt) =>
		keyCode = evt.keyCode or evt.which
		if keyCode < 48 || keyCode > 57
			if keyCode != 0 && keyCode != 8 && keyCode != 13 && keyCode != 110 && keyCode != 190 && keyCode != 188 && keyCode != 46 && !evt.ctrlKey
				evt.preventDefault()

	handleQuantityKeypress: (evt) =>
		keyCode = evt.keyCode or evt.which
		if keyCode < 48 || keyCode > 57
			if keyCode != 0 && keyCode != 8 && keyCode != 13 && !evt.ctrlKey
				evt.preventDefault()

	quantityInputChanged: (evt) =>
		$element = $(evt.target)
		@quantity = $element.val()
		@cleanQuantity()
		@updateUnitsFromQuantity()
		@update()
		@triggerProductEvent 'vtex.quantity.changed', @quantity #DEPRECATED
		@triggerProductEvent 'quantityChanged.vtex', @quantity #DEPRECATED

	cleanQuantity: =>
		@quantity = Math.round(@quantity)
		if @quantity > @options.max
			@quantity = @options.max
			alert("Por favor, escolha uma quantidade menor que #{@options.max}.")
		else if @quantity < @options.min
			@quantity = @options.min

	updateUnitsFromQuantity: =>
		@units = @quantity * @unitMultiplier
		@units = roundPlaces(@units, @options.decimalPlaces)


# PLUGIN ENTRY POINT
$.fn.quantitySelector = (productId, jsOptions) ->
	defaultOptions = $.extend true, {}, $.fn.quantitySelector.defaults
	for element in this
		$element = $(element)
		domOptions = $element.data()
		options = $.extend(true, defaultOptions, domOptions, jsOptions)
		unless $element.data('quantitySelector')
			$element.data('quantitySelector', new QuantitySelector($element, productId, options))

	return this

# PLUGIN DEFAULTS
$.fn.quantitySelector.defaults =
	initialQuantity: 1
	unitBased: false
	unitVariations: []
	max: 10
	min: 1
	decimalPlaces: 2