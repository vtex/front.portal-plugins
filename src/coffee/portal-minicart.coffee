$ = window.jQuery

#
# Class
#
class vtexMinicart
	constructor: (context, options) ->
		@options = $.extend {}, $.fn.vtexMinicart.defaults, options
		@context = context
		@hoverContext = @context.add('.show-minicart-on-hover')
		@cartData = @options.cartData	# default {}
		@init()

	getOrderFormURL: =>
		"/api/checkout/pub/orderForm/"

	getOrderFormUpdateURL: =>
		@getOrderFormURL() + @cartData.orderFormId + "/items/update/"

	init: =>
		@base = $('.minicartListBase').remove()

		@bindEvents()

		@getData().success (data) =>
			@updateCart data

	bindEvents: =>
		@hoverContext.add('.show-minicart-on-hover').on 'mouseover', ->
			$(window).trigger "minicartMouseOver"

		@hoverContext.add('.show-minicart-on-hover').on 'mouseout', ->
			$(window).trigger "minicartMouseOut"

		$(window).on "minicartMouseOver", =>
			if @cartData.items?.length > 0
				$(".vtexsc-cart").slideDown()
				clearTimeout @timeoutToHide

		$(window).on "minicartMouseOut", =>
			clearTimeout @timeoutToHide
			@timeoutToHide = setTimeout ->
				$(".vtexsc-cart").stop(true, true).slideUp()
			, 800

		$(window).on "cartUpdated", (event, cartData, show) =>
			if cartData?.items?.length is 0
				$(".vtexsc-cart").slideUp()
			else if show
				$(".vtexsc-cart").slideDown()
				@timeoutToHide = setTimeout ->
					$(".vtexsc-cart").stop(true, true).slideUp()
				, 3000

		$(window).on 'productAddedToCart', =>
			@getData().success (data) =>
				@updateCart(data)
				$(window).trigger "cartUpdated", [null, true]

	getData: =>
		$.ajax({
			url: @getOrderFormURL()
			data: JSON.stringify(expectedOrderFormSections: ["items", "paymentData", "totalizers"])
			dataType: "json"
			contentType: "application/json; charset=utf-8"
			type: "POST"
		})
		.done (data) =>
			@cartData = data
		.fail (jqXHR, textStatus, errorThrown) ->
			# console.log "Error Message: " + textStatus
			# console.log "HTTP Error: " + errorThrown

	updateCart: (data) =>
		data or= @cartData
		@updateValues data
		@updateItems data

	updateItems: (data) =>
		return unless data

		container = $(".vtexsc-productList tbody", @context).empty()
		for item, i in data.items
			now = @base.clone()
			now.find('.cartSkuImage a').attr('href', item.detailUrl)
			now.find('.cartSkuImage img').attr('alt', item.name).attr('src', item.imageUrl)
			now.find('.cartSkuName a').attr('href', item.detailUrl).text(item.name)
			now.find('.cartSkuPrice .bestPrice').text("R$ #{formatCurrency(item.price)}")
			now.find('.cartSkuQuantity .cartSkuQttTxt').text(item.quantity)

			now.appendTo(container)

		$(".vtexsc-productList .cartSkuRemove", @context).on 'click', =>
			@deleteItem(this)

	updateValues: (data) =>
		return unless data

		total = 0
		for subtotal in data.totalizers when subtotal.id is 'Items'
			total += subtotal.value

		$(".vtexsc-text", @context).text "R$ " + formatCurrency total

	deleteItem: (item) =>
		$(item).parent().find('.vtexsc-overlay').show()

		data = JSON.stringify
			expectedOrderFormSections: ["items", "paymentData", "totalizers"]
			orderItems: [
				index: $(item).data("index")
				quantity: 0
			]

		$.ajax({
			url: @getOrderFormUpdateURL()
			data: data
			dataType: "json"
			contentType: "application/json; charset=utf-8"
			type: "POST"
		})
		.success (data) =>
				@cartData = data
				@updateCart(data)
				$(window).trigger "cartUpdated", [data]
		.done ->
				$(item).parent().find('.vtexsc-overlay').hide()
		.fail (jqXHR, textStatus, errorThrown) ->
				# console.log "Error Message: " + textStatus
				# console.log "HTTP Error: " + errorThrown

	showMinicart: =>
		@getData().done =>
			@updateItems data
			$(".vtexsc-cart").slideDown()
			clearTimeout @timeoutToHide
			@timeoutToHide = setTimeout ->
				$(".vtexsc-cart").slideUp()
			, 3000


#
# Utils
#
formatCurrency = (value) ->
	if value is '' or not value? or isNaN value
		num = 0.00
	else
		num = value / 100
	parseFloat(num).toFixed(2).replace('.', ',').toString().replace(/(\d)(?=(\d\d\d)+(?!\d))/g, '$1.')


#
# Plugin
#
$.fn.vtexMinicart = (options) ->
	return this if @hasClass("plugin_vtexMinicart")
	@addClass("plugin_vtexMinicart")
	new vtexMinicart(this, options)
	return this

$.fn.vtexMinicart.defaults =
	cartData: {}


$ ->
	$('.portal-minicart-ref').vtexMinicart()
