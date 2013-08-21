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

		@select =
			amountProducts: => $('.amount-products-em', @context)
			amountItems: => $('.amount-items-em', @context)
			totalCart: => $('.total-cart-em', @context)

		@bindEvents()
		@updateCart()

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
			if cartData
				@cartData = cartData
				@prepareCart()
				@render()

				if cartData.items.length is 0
					$(".vtexsc-cart").slideUp()
				else if show
					$(".vtexsc-cart").slideDown()
					@timeoutToHide = setTimeout ->
						$(".vtexsc-cart").stop(true, true).slideUp()
					, 3000

			else
				@getData()

		$(window).on 'productAddedToCart', =>
			@updateCart()

	updateCart: =>
		@context.addClass 'amount-items-in-cart-loading'

		$.ajax({
			url: @getOrderFormURL()
			data:
				expectedOrderFormSections: @EXPECTED_ORDER_FORM_SECTIONS
			dataType: "json"
			contentType: "application/json; charset=utf-8"
			type: "POST"
		})
		.done =>
			@context.removeClass 'amount-items-in-cart-loading'
		.success (data) =>
			@cartData = data
			@prepareCart()
			@render()

	prepareCart: =>
		# Conditionals
		@cartData.showMinicart = @options.showMinicart
		@cartData.showTotalizers = @options.showTotalizers

		# Amount Items
		@cartData.amountItems = 0
		if @cartData.items
			@cartData.amountItems += item.quantity for item in @cartData.items

		# Total
		total = 0
		if @cartData.totalizers
			for subtotal in @cartData.totalizers
				total += subtotal.value if subtotal.id in ['Items', 'Discounts']
		@cartData.totalCart = _.intAsCurrency(total, @options)

		# Item labels
		if @cartData.items
			for item in @cartData.items
				item.availabilityMessage = @getAvailabilityMessage(item)
				item.formattedPrice = _.intAsCurrency(item.price, @options)

	render: () =>
		dust.render 'minicart', @cartData, (err, out) =>
			console.log 'Minicart Dust error: ', err if err
			@context.html out
			$(".vtexsc-productList .cartSkuRemove", @context).on 'click', =>
				@deleteItem(this)

	deleteItem: (item) =>
		$(item).parent().find('.vtexsc-overlay').show()

		$.ajax({
			url: @getOrderFormUpdateURL()
			data:
				expectedOrderFormSections: @EXPECTED_ORDER_FORM_SECTIONS
				orderItems: [
					index: $(item).data("index")
					quantity: 0
				]
			dataType: "json"
			contentType: "application/json; charset=utf-8"
			type: "POST"
		})
		.success (data) =>
			@cartData = data
			@prepareCart()
			@render()

	getAvailabilityCode: (item) =>
		item.availability or "available"

	getAvailabilityMessage: (item) =>
		@options.availabilityMessages[@getAvailabilityCode(item)]


#
# Plugin
#
$.fn.minicart = (options) ->
	for element in this
		$element = $(element)
		unless $element.hasClass("plugin_minicart")
			$element.addClass("plugin_minicart")
			new Minicart($element, options)

	# Chaining
	return this

$.fn.minicart.defaults =
	availabilityMessages:
		"available": ""
		"unavailableItemFulfillment": "Este item não está disponível no momento."
		"withoutStock": "Este item não está disponível no momento."
		"cannotBeDelivered": "Este item não está disponível no momento."
		"withoutPrice": "Este item não está disponível no momento."
		"withoutPriceRnB": "Este item não está disponível no momento."
		"nullPrice": "Este item não está disponível no momento."
	showMinicart: true
	showTotalizers: true


#
# EXPORTS
#
window.vtex or= {}
vtex.portalPlugins or= {}
vtex.portalPlugins.Minicart = Minicart
