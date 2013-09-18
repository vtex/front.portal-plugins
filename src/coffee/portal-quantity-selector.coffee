# DEPENDENCIES:
# jQuery

$ = window.jQuery

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

	init: =>
		@render()
		@bindEvents()
		@element.trigger 'vtex.quantity.ready', [@productId, @quantity]
		@element.trigger 'vtex.quantity.changed', [@productId, @quantity]

	render: =>
		renderData =
			unitBased: @options.unitBased
			units: @units
			unitMin: @unitMultiplier
			unitMax: @unitMultiplier * @options.max
			measurementUnit: @measurementUnit
			max: @options.max
			quantity: @quantity

		dust.render "quantity-selector", renderData, (err, out) =>
			throw new Error "Quantity Selector Dust error: #{err}" if err
			@element.html out

	bindEvents: =>
		@bindProductEvent 'vtex.sku.selected', @skuSelected
		@bindProductEvent 'vtex.quantity.changed', @quantityChanged
		@findUnitSelectorInput().on 'change', @unitInputChanged
		@findQuantitySelectorInput().on 'click', @quantityInputChanged

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
		unless (@quantity * @unitMultiplier) <= @units < ((@quantity+1) * @unitMultiplier)
			@quantity = Math.ceil(@units/@unitMultiplier)

	unitInputChanged: (evt) =>
		$element = $(evt.target)
		@units = $element.val()
		@updateQuantityFromUnits()
		@update()
		$element.trigger 'vtex.quantity.changed', [@productId, @quantity]

	quantityInputChanged: (evt) =>
		$element = $(evt.target)
		@quantity = $element.val()
		@updateUnitsFromQuantity()
		@update()
		$element.trigger 'vtex.quantity.changed', [@productId, @quantity]

	updateUnitsFromQuantity: =>
		@units = @quantity * @unitMultiplier


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
