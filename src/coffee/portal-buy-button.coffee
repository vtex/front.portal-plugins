# DEPENDENCIES:
# jQuery

$ = window.jQuery

# CLASSES
class BuyButton extends ProductComponent
	constructor: (@element, @productId, buyData = {}, @options) ->
		@sku = buyData.sku || null
		@quantity = buyData.quantity || 1
		@seller = buyData.seller || 1
		@salesChannel = buyData.salesChannel || 1

		if @options.multipleProductIds
			@manyProducts = {}
			for pid in @productId
				@manyProducts[pid] =
					sku: null
					quantity: 1
					seller: 1

		@accessories = []

		if CATALOG_SDK?
			@SDK = CATALOG_SDK
			@SDK.getProductWithVariations(@productId).done (json) =>
				@productData = json
				if @productData.skus.length == 1
					@triggerProductEvent('vtex.sku.selected', @productData.skus[0])
				@getChangesFromHREF()
				@update()

		@getChangesFromHREF()
		@bindEvents()
		@update()

	bindEvents: =>
		@bindProductEvent 'vtex.sku.selected', @skuSelected
		@bindProductEvent 'vtex.sku.unselected', @skuUnselected
		@bindProductEvent 'vtex.quantity.ready', @quantityChanged
		@bindProductEvent 'vtex.quantity.changed', @quantityChanged
		@bindProductEvent 'vtex.accessories.updated', @accessoriesUpdated
		@element.on 'click', @buyButtonHandler

	getChangesFromHREF: =>
		href = @element.attr 'href'
		if @_url != href

			skuMatch = href.match(/sku=(.*?)&/)
			if skuMatch and skuMatch[1] and skuMatch[1] != @sku
				@sku = skuMatch[1]
				@triggerProductEvent 'vtex.sku.changed', sku: @sku

			qtyMatch = href.match(/qty=(.*?)&/)
			if qtyMatch and qtyMatch[1] and qtyMatch[1] != @quantity
				@quantity = qtyMatch[1]
				@triggerProductEvent 'vtex.quantity.changed', @quantity

			sellerMatch = href.match(/seller=(.*?)&/)
			if sellerMatch and sellerMatch[1] and sellerMatch[1] != @seller
				@seller = sellerMatch[1]

			salesChannelMatch = href.match(/sc=(.*?)&/)
			if salesChannelMatch and salesChannelMatch[1] and salesChannelMatch[1] != @salesChannel
				@salesChannel = salesChannelMatch[1]

		@_url = href

	skuSelected: (evt, productId, sku) =>
		@getChangesFromHREF()

		if @options.multipleProductIds
			@manyProducts[productId].sku = sku
		else
			@skuData = sku
			@sku = sku.sku

		@update()
		@element.click() if @options.instaBuy and sku.available

	skuUnselected: (evt, productId, selectableSkus) =>
		@getChangesFromHREF()

		if @options.multipleProductIds
			@manyProducts[productId].sku = null
		else
			@skuData = {}
			@sku = null

		@update()

	quantityChanged: (evt, productId, quantity) =>
		@getChangesFromHREF()

		if @options.multipleProductIds
			@manyProducts[productId].quantity = quantity
		else
			@quantity = quantity

		@update()

	accessoriesUpdated: (evt, productId, accessories) =>
		@getChangesFromHREF()
		@accessories = accessories
		@update()

	getURL: =>
		queryParams = []

		if @options.multipleProductIds
			for id, prod of @manyProducts when prod.sku and prod.sku.available
				queryParams.push("sku=#{prod.sku.sku}")
				queryParams.push("qty=#{prod.quantity}")
				queryParams.push("seller=#{prod.seller}")
		else
			queryParams.push("sku=#{@sku}")
			queryParams.push("qty=#{@quantity}")
			queryParams.push("seller=#{@seller}")

		queryParams.push("redirect=#{@options.redirect}")
		queryParams.push("sc=#{@salesChannel}")

		for acc in @accessories when acc.quantity > 0
			queryParams.push("sku=#{acc.sku}")
			queryParams.push("qty=#{acc.quantity}")
			queryParams.push("seller=#{acc.sellerId}")

		if @options.giftRegistry
			queryParams.push("gr=#{@options.giftRegistry}")

		if @options.target
			queryParams.push("target=#{@options.target}")

		url = "/checkout/cart/add?#{queryParams.join('&')}"

		return url

	valid: => !!(@sku or @options.multipleProductIds)

	update: =>
		url = if @valid() then @getURL() else "javascript:alert('#{@options.errorMessage}');"
		@element.attr('href', url)
		@element.show()

		if @options.hideUnavailable and @skuData and @skuData.available is false
			@element.hide()
		if @options.hideUnselected and not @skuData
			@element.hide()
		if @productData and @productData.available is false
			@element.hide()

	buyButtonHandler: (evt) =>
		return true if @options.redirect or not @valid()

		$(window).trigger 'vtex.modal.hide'
		$.get(@getURL())
		.done =>
				@triggerProductEvent 'vtex.cart.productAdded'
				@triggerProductEvent 'productAddedToCart'
				alert @options.addMessage if @options.addMessage
		.fail =>
				@redirect = true
				window.location.href = @getURL()
				alert @options.errMessage if @options.errMessage

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
	addMessage: null
	errMessage: null
	instaBuy: false
	hideUnselected: false
	hideUnavailable: true
	target: null
	multipleProductIds: false
