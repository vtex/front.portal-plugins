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
		@bestPrice = buyData.bestPrice
		@cacheVersionUsedToCallCheckout = buyData.cacheVersionUsedToCallCheckout

		if @options.multipleProductIds
			@manyProducts = {}
			for pid in @productId
				@manyProducts[pid] =
					sku: null
					quantity: 1
					seller: 1
					bestPrice: null
					cacheVersionUsedToCallCheckout: null

		@accessories = []

		if CATALOG_SDK?
			@SDK = CATALOG_SDK
			@SDK.getProductWithVariations(@productId).done (json) =>
				@productData = json
				if @productData.skus.length == 1
					@triggerProductEvent 'vtex.sku.selected', @productData.skus[0] #DEPRECATED
					@triggerProductEvent 'skuSelected.vtex', @productData.skus[0]
				@getChangesFromHREF()
				@update()

		@getChangesFromHREF()
		@bindEvents()
		@update()

	bindEvents: =>
		@bindProductEvent 'skuSelected.vtex', @skuSelected
		@bindProductEvent 'skuUnselected.vtex', @skuUnselected
		@bindProductEvent 'quantityReady.vtex', @quantityChanged
		@bindProductEvent 'quantityChanged.vtex', @quantityChanged
		@bindProductEvent 'accessoriesUpdated.vtex', @accessoriesUpdated
		@element.on 'click', @buyButtonHandler

	getChangesFromHREF: =>
		href = @element.attr 'href'
		if @_url != href

			skuMatch = href.match(/sku=(.*?)&/)
			if skuMatch and skuMatch[1] and skuMatch[1] != @sku
				@sku = skuMatch[1]
				@triggerProductEvent 'vtex.sku.changed', sku: @sku #DEPRECATED
				@triggerProductEvent 'skuChanged.vtex', sku: @sku

			qtyMatch = href.match(/qty=(.*?)&/)
			if qtyMatch and qtyMatch[1] and qtyMatch[1] != @quantity
				@quantity = qtyMatch[1]
				@triggerProductEvent 'vtex.quantity.changed', @quantity #DEPRECATED
				@triggerProductEvent 'quantityChanged.vtex', @quantity

			sellerMatch = href.match(/seller=(.*?)&/)
			if sellerMatch and sellerMatch[1] and sellerMatch[1] != @seller
				@seller = sellerMatch[1]

			salesChannelMatch = href.match(/sc=(.*?)&/)
			if salesChannelMatch and salesChannelMatch[1] and salesChannelMatch[1] != @salesChannel
				@salesChannel = salesChannelMatch[1]

			bestPriceMatch = href.match(/price=(.*?)&/)
			if bestPriceMatch and bestPriceMatch[1] and bestPriceMatch[1] != @bestPrice
				@bestPrice = bestPriceMatch[1]

			cvMatch = href.match(/cv=(.*?)&/)
			if cvMatch and cvMatch[1] and cvMatch[1] != @cacheVersionUsedToCallCheckout
				@cacheVersionUsedToCallCheckout = cvMatch[1]

		@_url = href

	skuSelected: (evt, productId, sku) =>
		@getChangesFromHREF()

		if @options.multipleProductIds
			@manyProducts[productId].sku = sku
		else
			@skuData = sku
			@sku = sku.sku
			@seller = sku.sellerId
			@bestPrice = sku.bestPrice
			@cacheVersionUsedToCallCheckout = sku.cacheVersionUsedToCallCheckout

		@update()
		@element.click() if @options.instaBuy and sku.available

	skuUnselected: (evt, productId, selectableSkus) =>
		@getChangesFromHREF()

		if @options.multipleProductIds
			@manyProducts[productId].sku = null
		else
			@skuData = {}
			@sku = null
			@bestPrice = null
			@cacheVersionUsedToCallCheckout = null

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
		if not @valid()
			return @getErrorURL()

		queryParams = []

		if @options.multipleProductIds
			for id, prod of @manyProducts when prod.sku and prod.sku.available
				queryParams.push("sku=#{prod.sku.sku}")
				queryParams.push("qty=#{prod.quantity}")
				queryParams.push("seller=#{prod.seller}")
				queryParams.push("price=#{prod.sku.bestPrice}")
				queryParams.push("cv=#{prod.sku.cacheVersionUsedToCallCheckout}")
		else
			queryParams.push("sku=#{@sku}")
			queryParams.push("qty=#{@quantity}")
			queryParams.push("seller=#{@seller}")
			queryParams.push("price=#{@bestPrice}")
			queryParams.push("cv=#{@cacheVersionUsedToCallCheckout}")

		queryParams.push("redirect=#{@options.redirect}")
		queryParams.push("sc=#{@salesChannel}")

		for acc in @accessories when acc.quantity > 0
			queryParams.push("sku=#{acc.sku}")
			queryParams.push("qty=#{acc.quantity}")
			queryParams.push("seller=#{acc.sellerId}")
			queryParams.push("price=#{acc.bestPrice}")
			queryParams.push("cv=#{acc.cacheVersionUsedToCallCheckout}")

		if @options.giftRegistry
			queryParams.push("gr=#{@options.giftRegistry}")

		if @options.target
			queryParams.push("target=#{@options.target}")

		for key, value of @options.queryParams
			queryParams.push("#{key}=#{value}")

		url = "/checkout/cart/add?#{queryParams.join('&')}"

		return url

	getErrorURL: =>
		if @options.alertOnError
			"javascript:alert('#{@options.errorMessage}');"
		else
			"javascript:void(0);"

	valid: => !!(@sku or @options.multipleProductIds)

	update: =>
		@element.attr('href', @getURL())
		@element.show()

		if @options.hideUnavailable and @skuData and @skuData.available is false
			@element.hide()
		if @options.hideUnselected and not @skuData
			@element.hide()
		if @productData and @productData.available is false
			@element.hide()

	buyButtonHandler: (evt) =>
		if not @valid()
			@triggerProductEvent 'vtex.buyButton.failedAttempt', @options.errorMessage #DEPRECATED
			@triggerProductEvent 'buyButtonFailedAttempt.vtex', @options.errorMessage
			return true

		@triggerProductEvent 'vtex.buyButton.through', @getURL #DEPRECATED
		@triggerProductEvent 'buyButtonThrough.vtex', @getURL

		if @options.redirect
			return true

		$(window).trigger 'vtex.modal.hide' #DEPRECATED
		$(window).trigger 'modalHide.vtex'

		$.get(@getURL())
		.done =>
			@triggerProductEvent 'productAddedToCart' #DEPRECATED
			@triggerProductEvent 'vtex.cart.productAdded' #DEPRECATED
			@triggerProductEvent 'cartProductAdded.vtex'
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
	alertOnError: true
	redirect: true
	addMessage: null
	errMessage: null
	instaBuy: false
	hideUnselected: false
	hideUnavailable: true
	target: null
	multipleProductIds: false
	queryParams: {}
