# DEPENDENCIES:
# jQuery

$ = window.jQuery

# CLASS
class QuantitySelector
	constructor: (@element, @productId, @quantity = 1, @options) ->
		@init()

	init: =>
		@render()
		@bindEvents()
		@element.trigger 'vtex.quantity.ready', [@productId, @quantity]

	render: =>
		renderData =
			availableQuantities: [1..@options.max]
			max: @options.max
			quantity: @quantity
			text: @options.text
			style:
				select: @options.style is 'select'
				text: @options.style is 'text'
				number: @options.style is 'number'
			readonly: @options.readonly

		dust.render "quantity-selector", renderData, (err, out) =>
			console.log "Quantity Selector Dust error: ", err if err
			@element.html out
			@update()

	update: =>
		@element.find('.produtoQuantidade').val(@quantity)

	bindEvents: =>
		$(window).on 'vtex.quantity.changed', @quantityChanged
		@element.find('.menos').on 'click', @decrementQuantity
		@element.find('.mais').on 'click', @incrementQuantity
		@element.find('input,select').on 'change', (evt) =>
			$el = $(evt.target)
			$el.trigger 'vtex.quantity.changed', [@productId, $el.val()]

	check: (productId) =>
		productId == @productId

	quantityChanged: (evt, productId, quantity) =>
		return unless @check(productId)
		@quantity = quantity
		@update()

	decrementQuantity: =>
		if @quantity > 1
			@element.trigger 'vtex.quantity.changed', [@productId, @quantity-1]
		return false

	incrementQuantity: =>
		if @quantity < @options.max
			@element.trigger 'vtex.quantity.changed', [@productId, @quantity+1]
		return false


# PLUGIN ENTRY POINT
$.fn.quantitySelector = (productId, quantity = 1, jsOptions) ->
	defaultOptions = $.extend true, {}, $.fn.quantitySelector.defaults
	for element in this
		$element = $(element)
		domOptions = $element.data()
		options = $.extend(true, defaultOptions, domOptions, jsOptions)
		unless $element.data('quantitySelector')
			$element.data('quantitySelector', new QuantitySelector($element, productId, quantity, options))

	return this

# PLUGIN DEFAULTS
$.fn.quantitySelector.defaults =
	text: "Selecione a quantidade:"
	style: 'text'
	readonly: true
	max: 5
