$ = window.jQuery

#
# Class
#
class Minicart
	constructor: (context, options) ->
		@EXPECTED_ORDER_FORM_SECTIONS = ["items", "paymentData", "totalizers"]

		@options = $.extend {}, $.fn.minicart.defaults, options
		@context = context
		@hoverContext = @context.add('.show-minicart-on-hover')
		@cartData = {}

		@base = $('.minicartListBase').remove()

		@bindEvents()

		@updateData().success @updateCart

		$(window).trigger "minicartLoaded"

	getOrderFormURL: =>
		"/api/checkout/pub/orderForm/"

	getOrderFormUpdateURL: =>
		@getOrderFormURL() + @cartData.orderFormId + "/items/update/"

	bindEvents: =>
		@hoverContext.on 'mouseover', ->
			$(window).trigger "minicartMouseOver"

		@hoverContext.on 'mouseout', ->
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
			@updateData().success =>
				@updateCart()
				$(window).trigger "cartUpdated", [null, true]

	updateData: =>
		$.ajax({
			url: @getOrderFormURL()
			data: expectedOrderFormSections: @EXPECTED_ORDER_FORM_SECTIONS
			dataType: "json"
			contentType: "application/json; charset=utf-8"
			type: "POST"
		})
		.done (data) =>
			@cartData = data
		.fail (jqXHR, textStatus, errorThrown) ->
			# console.log "Error Message: " + textStatus
			# console.log "HTTP Error: " + errorThrown

	updateCart: () =>
		@updateValues()
		@updateItems()

	updateValues: =>
		total = 0
		for subtotal in @cartData.totalizers when subtotal.id is 'Items'
			total += subtotal.value

		$(".vtexsc-text", @context).text(@getValueLabel(total))

	updateItems: =>
		container = $(".minicartListContainer", @context).empty()
		for item, i in @cartData.items
			current = @base.clone()

			current.find('.cartSkuImage a').attr('href', item.detailUrl)
			current.find('.cartSkuImage img').attr('alt', item.name).attr('src', item.imageUrl)
			current.find('.cartSkuName a').attr('href', item.detailUrl).text(item.name)
			current.find('.cartSkuName .availability').text(@getAvailabilityMessage(item)).addClass("availability-#{@getAvailabilityCode(item)}")
			current.find('.cartSkuPrice .bestPrice').text(@getValueLabel(item.price))
			current.find('.cartSkuQuantity .cartSkuQttTxt').text(item.quantity)

			current.appendTo(container)

		$(".vtexsc-productList .cartSkuRemove", @context).on 'click', =>
			@deleteItem(this)

	deleteItem: (item) =>
		$(item).parent().find('.vtexsc-overlay').show()

		data =
			expectedOrderFormSections: @EXPECTED_ORDER_FORM_SECTIONS
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

	getValueLabel: (value) =>
		@options.valuePrefix + _.formatCurrency(value/100, @options) + @options.valueSufix

	getAvailabilityCode: (item) =>
		item.availability or "available"

	getAvailabilityMessage: (item) =>
		@options.availabilityMessages[@getAvailabilityCode(item)]


#
# Plugin
#
$.fn.minicart = (options) ->
	return this if @hasClass("plugin_minicart")
	@addClass("plugin_minicart")
	new Minicart(this, options)
	return this

$.fn.minicart.defaults =
	cartData: {}
	valuePrefix: "R$ "
	valueSufix: ""
	availabilityMessages:
		"available": ""
		"unavailableItemFulfillment": "Este item não está disponível no momento."
		"withoutStock": "Este item não está disponível no momento."
		"cannotBeDelivered": "Este item não está disponível no momento."
		"withoutPrice": "Este item não está disponível no momento."
		"withoutPriceRnB": "Este item não está disponível no momento."
		"nullPrice": "Este item não está disponível no momento."


#
# EXPORTS
#
window.vtex or= {}
vtex.portalPlugins or= {}
vtex.portalPlugins.Minicart = Minicart
