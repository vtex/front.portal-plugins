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

	render: =>
		$template = $($.qtySelector.template)
		$template.find('.produtoQuantidade').attr('readonly', 'readonly') if @options.readonly
		$template.find('.produtoQuantidade').val(@qty)
		@element.html $template

	bindEvents: =>
		$(window).on 'vtex.qty.changed', @qtyChanged
		@element.find('.menos').on 'click', @decrementQty
		@element.find('.mais').on 'click', @incrementQty

	check: (productId) =>
		productId == @productId

	qtyChanged: (evt, qty, productId) =>
		return unless @check(productId)
		@qty = qty
		@init()

	decrementQty: =>
		if @qty > 1
			@element.trigger 'vtex.qty.changed', [@qty-1, @productId]

	incrementQty: =>
		if @qty < @options.max
			@element.trigger 'vtex.qty.changed', [@qty+1, @productId]


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
	readonly: true
	max: 999

# PLUGIN SHARED
$.qtySelector =
	template: """
						<div class="quantidade" style="display: block;">
						<p class="txtQuantidade">Selecione a quantidade:</p>
						<a href="#" class="menos">-</a>
						<input type="text" class="produtoQuantidade">
						<a href="#" class="mais">+</a>
						</div>
						"""