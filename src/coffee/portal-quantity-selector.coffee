# DEPENDENCIES:
# jQuery

$ = window.jQuery

# CLASS
class QuantitySelector extends ProductComponent
	constructor: (@element, @productId, @options) ->
		@units = @options.unitMultiplier * @options.initialQuantity
		@quantity = @options.initialQuantity
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
			unitMin: @options.unitMultiplier
			unitMax: @options.unitMultiplier * @options.max
			unitOfMeasurement: @options.unitOfMeasurement
			max: @options.max
			quantity: @quantity

		dust.render "quantity-selector", renderData, (err, out) =>
			throw new Error "Quantity Selector Dust error: #{err}" if err
			@element.html out
			@update()

	bindEvents: =>
		@bindProductEvent 'vtex.quantity.changed', @quantityChanged
		@element.find('.unitSelector input').on 'change', @unitInputChanged
		@element.find('.quantitySelector input').on 'click', @quantityInputChanged

	update: =>
		@element.find('.unitSelector input').val(@units)
		@element.find('.quantitySelector input').val(@quantity)

	check: (productId) =>
		productId == @productId

	quantityChanged: (evt, productId, quantity) =>
		@quantity = quantity
		unless (@quantity * @options.unitMultiplier) <= @units < ((@quantity+1) * @options.unitMultiplier)
			@quantity = @calculateQuantity()
		@update()

	unitInputChanged: (evt) =>
		$element = $(evt.target)
		@units = $element.val()
		@quantity = @calculateQuantity()
		@update()
		$element.trigger 'vtex.quantity.changed', [@productId, @quantity]

	calculateQuantity: =>
		Math.ceil(@units/@options.unitMultiplier)

	quantityInputChanged: (evt) =>
		$element = $(evt.target)
		@quantity = $element.val()
		@units = @calculateUnits()
		@update()
		$element.trigger 'vtex.quantity.changed', [@productId, @quantity]

	calculateUnits: =>
		@quantity * @options.unitMultiplier

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
	unitOfMeasurement: ''
	unitMultiplier: 1
	max: 10
