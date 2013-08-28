# DEPENDENCIES:
# jQuery

$ = window.jQuery

# CLASS
class QtySelector
	constructor: (element, productId, qty = 1, options) ->
		@element = element
		@productId = productId
		@qty = qty
		@options = options

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
	# Gather options
	domOptions = this.data()
	defaultOptions = $.fn.qtySelector.defaults
	# Build final options object (priority: js, then dom, then default)
	# Deep extending with true, for the selectors
	options = $.extend(true, defaultOptions, domOptions, jsOptions)

	new QtySelector(this, productId, qty, options)

	# Chaining
	return this

# PLUGIN DEFAULTS
$.fn.qtySelector.defaults =
	text: "Selecione a quantidade:"
	style: 'text'
	readonly: true
	max: 5
