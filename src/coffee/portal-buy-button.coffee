# DEPENDENCIES:
# jQuery

$ = window.jQuery

# CLASSES
class BuyButton
	constructor: (element, productId, buyData = {}, options) ->
		@element = element
		@productId = productId
		@sku = buyData.sku || null
		@qty = buyData.qty || 1
		@seller = buyData.seller || 1
		@salesChannel = buyData.salesChannel || 1
		@options = options

		@init()

	init: =>
		@bindEvents()
		@update()

	bindEvents: =>
		$(window).on 'vtex.sku.selected', @skuSelected
		$(window).on 'vtex.sku.unselected', @skuUnselected
		$(window).on 'vtex.qty.changed', @qtyChanged
		@element.on 'click', @buyButtonHandler

	check: (productId) =>
		productId == @productId

	skuSelected: (evt, sku, product) =>
		return unless @check(product.productId)
		@sku = sku.sku
		@update()

	skuUnselected: (evt, sku, product) =>
		return unless @check(product.productId)
		@sku = null
		@update()

	qtyChanged: (evt, qty, product) =>
		return unless @check(product.productId)
		@qty = qty
		@update()

	getURL: =>
		"/checkout/cart/add?sku=#{@sku}&qty=#{@qty}&seller=#{@seller}&sc=#{@salesChannel}&redirect=#{@options.redirect}"

	update: =>
		url = if @sku then @getURL() else "javascript:alert('#{@options.errorMessage}');"
		@element.attr('href', url)

	buyButtonHandler: (evt) =>
		return true if @redirect

		context.trigger 'vtex.modal.hide'
		$.get(@getURL())
		.done ->
			$(window).trigger 'vtex.cart.productAdded'
			$(window).trigger 'productAddedToCart'
		.fail ->
			@redirect = true
			window.location.href = @getURL()

		evt.preventDefault()
		return false


# PLUGIN ENTRY POINT
$.fn.buyButton = (productId, buyData, jsOptions) ->
	# Gather options
	domOptions = this.data()
	defaultOptions = $.fn.buyButton.defaults
	# Build final options object (priority: js, then dom, then default)
	# Deep extending with true, for the selectors
	options = $.extend(true, defaultOptions, domOptions, jsOptions)

	new BuyButton(this, productId, buyData, options)


# PLUGIN DEFAULTS
$.fn.buyButton.defaults =
	errorMessage: "Por favor, selecione o modelo desejado."
	redirect: true
