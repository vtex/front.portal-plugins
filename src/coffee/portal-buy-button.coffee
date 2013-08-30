# DEPENDENCIES:
# jQuery

$ = window.jQuery

# CLASSES
class BuyButton
	constructor: (@element, @productId, buyData = {}, @options) ->
		@sku = buyData.sku || null
		@qty = buyData.qty || 1
		@seller = buyData.seller || 1
		@salesChannel = buyData.salesChannel || 1

		@accessories = []

		@init()

	init: =>
		@bindEvents()
		@update()

	bindEvents: =>
		$(window).on 'vtex.sku.selected', @skuSelected
		$(window).on 'vtex.sku.unselected', @skuUnselected
		$(window).on 'vtex.qty.ready', @qtyChanged
		$(window).on 'vtex.qty.changed', @qtyChanged
		$(window).on 'vtex.accessory.selected', @accessorySelected
		@element.on 'click', @buyButtonHandler

	check: (productId) =>
		productId == @productId

	skuSelected: (evt, sku, productId) =>
		return unless @check(productId)
		@sku = sku.sku
		@update()

	skuUnselected: (evt, selectableSkus, productId) =>
		return unless @check(productId)
		@sku = null
		@update()

	qtyChanged: (evt, qty, productId) =>
		return unless @check(productId)
		@qty = qty
		@update()

	accessorySelected: (evt, accessory, productId) =>
		return unless @check(productId)
		found = false
		for acc, i in @accessories
			if acc.productId = accessory.productId
				@accessories[i] = accessory
				found = true
		unless found
			@accessories.push(accessory)
		@update()

	getURL: =>
		url = "/checkout/cart/add?sku=#{@sku}&qty=#{@qty}&seller=#{@seller}&sc=#{@salesChannel}&redirect=#{@options.redirect}"
		for acc in @accessories when acc.qty > 0
			url += "&sku=#{acc.sku}&qty=#{acc.qty}&seller=#{acc.sellerId}&sc=#{acc.salesChannel}"
		return url

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
	defaultOptions = $.extend true, {}, $.fn.buyButton.defaults
	for element in this
		$element = $(element)
		domOptions = $element.data()
		options = $.extend(true, defaultOptions, domOptions, jsOptions)
		unless $element.data('buyButton')
			$element.data('buyButton', new BuyButton($element, productId, buyData, options))

	return this


# PLUGIN DEFAULTS
$.fn.buyButton.defaults =
	errorMessage: "Por favor, selecione o modelo desejado."
	redirect: true
