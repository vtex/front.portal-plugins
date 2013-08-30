# DEPENDENCIES:
# jQuery

$ = window.jQuery

# CLASS
class QtySelector
	constructor: (@element, @productId, @qty = 1, @options) ->
		@init()

	init: =>
		@render()
		@bindEvents()
		@element.trigger 'vtex.qty.ready', [@qty, @productId]

	render: =>
		renderData =
			availableQuantities: [1..@options.max]
			max: @options.max
			qty: @qty
			text: @options.text
			style:
				select: @options.style is 'select'
				text: @options.style is 'text'
				number: @options.style is 'number'
			readonly: @options.readonly

		dust.render "qty-selector", renderData, (err, out) =>
			console.log "Qty Selector Dust error: ", err if err
			@element.html out
			@update()

	update: =>
		@element.find('.produtoQuantidade').val(@qty)

	bindEvents: =>
		$(window).on 'vtex.qty.changed', @qtyChanged
		@element.find('.menos').on 'click', @decrementQty
		@element.find('.mais').on 'click', @incrementQty
		@element.find('input,select').on 'change', (evt) =>
			$el = $(evt.target)
			$el.trigger 'vtex.qty.changed', [$el.val(), @productId]

	check: (productId) =>
		productId == @productId

	qtyChanged: (evt, qty, productId) =>
		return unless @check(productId)
		@qty = qty
		@update()

	decrementQty: =>
		if @qty > 1
			@element.trigger 'vtex.qty.changed', [@qty-1, @productId]
		return false

	incrementQty: =>
		if @qty < @options.max
			@element.trigger 'vtex.qty.changed', [@qty+1, @productId]
		return false


# PLUGIN ENTRY POINT
$.fn.qtySelector = (productId, qty = 1, jsOptions) ->
	defaultOptions = $.extend true, {}, $.fn.qtySelector.defaults
	for element in this
		$element = $(element)
		domOptions = $element.data()
		options = $.extend(true, defaultOptions, domOptions, jsOptions)
		unless $element.data('qtySelector')
			$element.data('qtySelector', new QtySelector($element, productId, qty, options))

	return this

# PLUGIN DEFAULTS
$.fn.qtySelector.defaults =
	text: "Selecione a quantidade:"
	style: 'text'
	readonly: true
	max: 5
