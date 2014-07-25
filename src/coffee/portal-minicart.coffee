# DEPENDENCIES:
# jQuery
# vtex-utils
# dust

$ = window.jQuery

# CLASS
class Minicart
	constructor: (@element, @options) ->
		@EXPECTED_ORDER_FORM_SECTIONS = ["items", "paymentData", "totalizers"]

		@hoverContext = @element.add('.show-minicart-on-hover')
		@cartData = {}

		@base = $('.minicartListBase').remove()

		@select =
			amountProducts: => $('.amount-products-em', @element)
			amountItems: => $('.amount-items-em', @element)
			totalCart: => $('.total-cart-em', @element)

		@bindEvents()
		@updateCart(false)

		$(window).trigger "minicartLoaded"

	getOrderFormURL: =>
		@options.orderFormURL

	getOrderFormUpdateURL: =>
		@getOrderFormURL() + @cartData.orderFormId + "/items/update/"

	bindEvents: =>
		@hoverContext.on 'mouseover', =>
			$(window).trigger "minicartMouseOver" #DEPRECATED
			@element.trigger 'vtex.minicart.mouseOver' #DEPRECATED
			$(window).trigger "minicartMouseOver.vtex"

		@hoverContext.on 'mouseout', =>
			$(window).trigger "minicartMouseOut" #DEPRECATED
			@element.trigger 'vtex.minicart.mouseOut' #DEPRECATED
			$(window).trigger "minicartMouseOut.vtex"

		$(window).on "minicartMouseOver.vtex", =>
			if @cartData.items?.length > 0
				$(".vtexsc-cart").slideDown()
				clearTimeout @timeoutToHide

		$(window).on "minicartMouseOut.vtex", =>
			clearTimeout @timeoutToHide
			@timeoutToHide = setTimeout ->
				$(".vtexsc-cart").stop(true, true).slideUp()
			, 800

		$(window).on "cartUpdated", (evt, args...) => @updateCart(args...)
		$(window).on 'cartProductAdded.vtex', (evt, args...) => @updateCart(args...)
		$(window).on 'cartProductRemoved.vtex', (evt, args...) => @updateCart(args...)
		$(window).on 'orderFormUpdated.vtex', (evt, args...) => @handleOrderForm(args...)

	updateCart: (slide = true) =>
		@element.addClass 'amount-items-in-cart-loading'

		$.ajax({
			url: @getOrderFormURL()
			data:
				JSON.stringify expectedOrderFormSections: @EXPECTED_ORDER_FORM_SECTIONS
			dataType: "json"
			contentType: "application/json; charset=utf-8"
			type: "POST"
		})
		.done =>
			@element.removeClass 'amount-items-in-cart-loading'
			@element.trigger 'vtex.minicart.updated' #DEPRECATED
			@element.trigger 'minicartUpdated.vtex'
		.success (data) =>
			@handleOrderForm(data, slide)

	handleOrderForm: (orderForm, slide = true) =>
		@cartData.orderFormId = orderForm?.orderFormId
		@cartData.totalizers = orderForm?.totalizers
		if orderForm?.items?
			@cartData.items = orderForm.items
			@prepareCart()
			@render()
			@slide() if slide

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
				item.formattedPrice = _.intAsCurrency(item.sellingPrice, @options) + if item.measurementUnit and item.measurementUnit != 'un' then " (por cada #{item.unitMultiplier} #{item.measurementUnit})" else ''

	render: () =>
		dust.render 'minicart', $.extend({options: @options}, @cartData), (err, out) =>
			throw new Error "Minicart Dust error: #{err}" if err
			@element.html out
			$(".vtexsc-productList .cartSkuRemove", @element).on 'click', (evt) =>
				@deleteItem(evt.target)

	slide: =>
		if @cartData.items.length is 0
			@element.find(".vtexsc-cart").slideUp()
		else
			@element.find(".vtexsc-cart").slideDown()
			@timeoutToHide = setTimeout =>
				@element.find(".vtexsc-cart").stop(true, true).slideUp()
			, 3000

	deleteItem: (item) =>
		$(item).parent().find('.vtexsc-overlay').show()

		$.ajax({
			url: @getOrderFormUpdateURL()
			data:
				JSON.stringify
					expectedOrderFormSections: @EXPECTED_ORDER_FORM_SECTIONS
					orderItems: [
						index: $(item).data("index")
						quantity: 0
					]
			dataType: "json"
			contentType: "application/json; charset=utf-8"
			type: "POST"
		})
		.done =>
			@element.trigger 'vtex.minicart.updated' #DEPRECATED
			@element.trigger 'minicartUpdated.vtex'
		.success (data) =>
			@element.trigger 'vtex.cart.productRemoved' #DEPRECATED
			@element.trigger 'cartProductRemoved.vtex'
			@cartData = data
			@prepareCart()
			@render()
			@slide()

	getAvailabilityCode: (item) =>
		item.availability or "available"

	getAvailabilityMessage: (item) =>
		@options.availabilityMessages[@getAvailabilityCode(item)]


# PLUGIN ENTRY POINT
$.fn.minicart = (jsOptions) ->
	defaultOptions = $.extend true, {}, $.fn.minicart.defaults
	for element in this
		$element = $(element)
		domOptions = $element.data()
		options = $.extend(true, defaultOptions, domOptions, jsOptions)
		unless $element.data('minicart')
			$element.data('minicart', new Minicart($element, options))

	return this

# PLUGIN DEFAULTS
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
	orderFormURL: "/api/checkout/pub/orderForm/"
	checkoutHash: '/orderform'
