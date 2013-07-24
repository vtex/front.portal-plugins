$ = window.jQuery

#
# Class
#
class vtexTotalizers
	constructor: (context, options) ->
		@options = $.extend {}, $.fn.vtexTotalizers.defaults, options
		@context = context

		@select =
			amountProducts: => $('.amount-products-em', @context)
			amountItems: => $('.amount-items-em', @context)
			totalCart: => $('.total-cart-em', @context)

		@getCartData()
		@bindEvents

	bindEvents: =>
		$(window).on 'cartUpdated', (event, cartData) =>
			if (cartData)
				@setCartData(cartData)
			else
				@getCartData()

	getCartData: =>
		$(@context).addClass 'amount-items-in-cart-loading'

		$.ajax({
			url: '/api/checkout/pub/orderForm/'
			data: JSON.stringify {"expectedOrderFormSections": ["items", "paymentData", "totalizers"]}
			dataType: 'json'
			contentType: 'application/json; charset=utf-8'
			type: 'POST'
		})
		.done (data) =>
			$(@context).removeClass 'amount-items-in-cart-loading'
		.success (data) =>
			@setCartData data
		.fail (jqXHR, textStatus, errorThrown) =>
			# console.log 'Error Message: ' + textStatus;
			# console.log 'HTTP Error: ' + errorThrown;

	setCartData: (data) =>
		amountProducts = data.items.length
		amountItems = 0;
		amountItems += item.quantity for item in data.items

		total = 0
		for subtotal in data.totalizers
			total += subtotal.value if subtotal.id is 'Items'
		totalCart = _.formatCurrency(total / 100)

		@select.amountProducts().text amountProducts
		@select.amountItems().text amountItems
		@select.totalCart().text totalCart

#
# Plugin
#
$.fn.vtexTotalizers = (options) ->
	return this if @hasClass("plugin_vtexTotalizers")
	@addClass("plugin_vtexTotalizers")
	new vtexTotalizers(this, options)
	return this

$.fn.vtexTotalizers.defaults = {}
