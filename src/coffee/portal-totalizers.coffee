$ = window.jQuery

#
# Class
#
class vtexTotalizers
	constructor: (@element, options) ->
		@options = $.extend {}, $.fn.vtexTotalizers.defaults, options

		@init()

	init: =>
		@options.$template = $ """
		<div class="amount-items-in-cart amount-items-in-cart-loading">
			<div class="cartInfoWrapper">
				<span class="title"><span id="MostraTextoXml1">Resumo do Carrinho</span></span>
				<ul class="cart-info">
					<li class="amount-products">
						<strong><span id="MostraTextoXml2">Total de Produtos:</span></strong> <em class="amount-products-em">0</em>
					</li>
					<li class="amount-items">
						<strong><span id="MostraTextoXml3">Itens:</span></strong> <em class="amount-items-em">0</em>
					</li>
					<li class="amount-kits">
						<strong><span id="MostraTextoXml4">Total de Kits:</span></strong> <em class="amount-kits-em">0</em>
					</li>
					<li class="total-cart">
						<strong><span id="MostraTextoXml5">Valor Total:</span></strong> R$ <em class="total-cart-em">0,00</em>
					</li>
				</ul>
			</div>
		</div>
		"""

		$(@element).after @options.$template

		@selectors = {
			amountProducts: $('.amount-products-em', @options.$template)
			amountItems: $('.amount-items-em', @options.$template)
			totalCart: $('.total-cart-em', @options.$template)
		}

		@getCartData()

		$(window).on 'cartUpdated', (event, cartData) =>
			if (cartData)
				@setCartData(cartData)
			else
				@getCartData()

		$('.amount-items-in-cart, .show-minicart-on-hover').on 'mouseover', ->
			$(window).trigger 'miniCartMouseOver'

		$('.amount-items-in-cart, .show-minicart-on-hover').on 'mouseout', ->
			$(window).trigger 'miniCartMouseOut'

	formatCurrency: (value) ->
		if value is '' or not value? or isNaN value
			num = 0.00
		else
			num = value / 100
		parseFloat(num).toFixed(2).replace('.', ',').toString().replace(/(\d)(?=(\d\d\d)+(?!\d))/g, '$1.')

	getCartData: =>
		$(@options.$template).addClass 'amount-items-in-cart-loading'

		$.ajax({
			url: '/api/checkout/pub/orderForm/'
			data: JSON.stringify {"expectedOrderFormSections": ["items", "paymentData", "totalizers"]}
			dataType: 'json'
			contentType: 'application/json; charset=utf-8'
			type: 'POST'
		})
		.done (data) =>
			$(@options.$template).removeClass 'amount-items-in-cart-loading'
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
		totalCart = @formatCurrency(total)

		@selectors.amountProducts.html amountProducts
		@selectors.amountItems.html amountItems
		@selectors.totalCart.html totalCart

#
# Plugin
#
$.fn.vtexTotalizers = (options) ->
	return this if @hasClass("plugin_vtexTotalizers")
	@addClass("plugin_vtexTotalizers")
	new vtexTotalizers(this, options)
	return this

$.fn.vtexTotalizers.defaults = {}
