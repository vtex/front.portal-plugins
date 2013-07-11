$ = window.jQuery

#
# Class
#
class vtexMinicart
	constructor: (@element, options) ->
		@options = $.extend {}, $.fn.vtexMinicart.defaults, options
		@init()

	init: =>
		self = this

		self.options.$template = $ """
		<div class="v2-vtexsc-cart vtexsc-cart mouseActivated preLoaded" style="display: none;">
			<div class="vtexsc-bt"></div>
			<div class="vtexsc-center">
					<div class="vtexsc-wrap">
							<table class="vtexsc-productList">
									<thead style="display: none;">
											<tr>
													<th class="cartSkuName" colspan="2">Produto</th>
													<th class="cartSkuPrice">Preço</th>
													<th class="cartSkuQuantity">Quantidade</th>
													<th class="cartSkuActions">Excluir</th>
											</tr>
									</thead>
									<tbody></tbody>
							</table>
					</div>
					<div class="cartFooter clearfix">
							<div class="cartTotal">
									Total\
									<span class="vtexsc-totalCart">
											<span class="vtexsc-text">R$ 0</span>
									</span>
							</div>
							<a href="/checkout/#/orderform" class="cartCheckout"></a>
					</div>
			</div>
			<div class="vtexsc-bb"></div>
		</div>
		"""

		$(@element).after @options.$template

		$(@options.$template)
		.mouseover ->
			$(window).trigger "miniCartMouseOver"
		.mouseout ->
			$(window).trigger "miniCartMouseOut"

		$(window).on "miniCartMouseOver", ->
			if self.options.cartData?.items.length > 0
				$(".vtexsc-cart").slideDown()
				clearTimeout self.options.timeoutToHide

		$(window).on "miniCartMouseOut", ->
			clearTimeout self.options.timeoutToHide
			self.options.timeoutToHide = setTimeout ->
				$(".vtexsc-cart").stop(true, true).slideUp()
			, 800

		$(window).on "cartUpdated", (event, cartData, show) ->
			if cartData?.items? and cartData.items.length is 0
				$(".vtexsc-cart").slideUp()
				return
			if show
				$(".vtexsc-cart").slideDown()
				self.options.timeoutToHide = setTimeout ->
					$(".vtexsc-cart").stop(true, true).slideUp()
				, 3000

		$(window).on 'productAddedToCart', ->
			self.getData().success (data) ->
				self.updateItems data
				self.changeCartValues data
				$(window).trigger "cartUpdated", [null, true]

		@getData().success (data) =>
			@insertCartItems data
			@changeCartValues data


	getData: =>
		$.ajax({
			url: "/api/checkout/pub/orderForm/"
			data: JSON.stringify(expectedOrderFormSections: ["items", "paymentData", "totalizers"])
			dataType: "json"
			contentType: "application/json; charset=utf-8"
			type: "POST"
		})
		.done (data) =>
			@options.cartData = data
		.fail (jqXHR, textStatus, errorThrown) ->
			# console.log "Error Message: " + textStatus
			# console.log "HTTP Error: " + errorThrown

	insertCartItems: (data) =>
		return unless data

		total = 0
		for subtotal in data.totalizers when subtotal.id is 'Items'
			total += subtotal.value

		$('.vtexsc-text', @options.$template).text 'R$' + formatCurrency(total)
		@updateItems data

	deleteItem: (item) =>
		$(item).parent().find('.vtexsc-overlay').show()

		data = JSON.stringify
			expectedOrderFormSections: ["items", "paymentData", "totalizers"]
			orderItems: [
				index: $(item).data("index")
				quantity: 0
			]

		$.ajax({
			url: "/api/checkout/pub/orderForm/" + self.options.cartData.orderFormId + "/items/update/"
			data: data
			dataType: "json"
			contentType: "application/json; charset=utf-8"
			type: "POST"
		})
		.success (data) =>
			@options.cartData = data
			@changeCartValues data
			@updateItems data
			$(window).trigger "cartUpdated", [data]
		.done ->
			$(item).parent().find('.vtexsc-overlay').hide()
		.fail (jqXHR, textStatus, errorThrown) ->
			# console.log "Error Message: " + textStatus
			# console.log "HTTP Error: " + errorThrown

	updateItems: (data) =>
		return unless data

		items = ''

		for item, i in data.items
			items += """
			<tr>
					<td class="cartSkuImage">
							<a class="sku-imagem" href="#{item.detailUrl}"><img height="71" width="71" alt="#{item.name}" src="#{item.imageUrl}" /></a>
					</td>
					<td class="cartSkuName">
							<h4><a href="#{item.detailUrl}">"#{item.name}"</a><br /></h4>
					</td>
					<td class="cartSkuPrice">
							<div class="cartSkuUnitPrice">
									<span class="bestPrice">R$ #{formatCurrency(item.price)}</span>
							</div>
					</td>
					<td class="cartSkuQuantity">
							<div class="cartSkuQtt">
									<span class="cartSkuQttTxt"><span class="vtexsc-skuQtt">#{item.quantity}</span></span>
							</div>
					</td>
					<td class="cartSkuActions">
							<span class="cartSkuRemove" data-index="#{i}">
									<a href="javascript:void(0);" class="text" style="display: none;">excluir</a>
							</span>
							<div class="vtexsc-overlay" style="display: none;"></div>
					</td>
			</tr>
			"""

		$(".vtexsc-productList tbody", @options.$template).html items

		self = this
		$(".vtexsc-productList .cartSkuRemove", @options.$template).click ->
			self.deleteItem(this)

	changeCartValues: (data) =>
		return unless data

		total = 0
		for subtotal in data.totalizers when subtotal.id is 'Items'
			total += subtotal.value

		$(".vtexsc-text", @options.$template).text "R$ " + formatCurrency total

	showMinicart: (value) =>
		@getData().done =>
			@updateItems data
			$(".vtexsc-cart").slideDown()
			clearTimeout @options.timeoutToHide
			@options.timeoutToHide = setTimeout ->
				$(".vtexsc-cart").slideUp()
			, 3000


#
# Utils
#
formatCurrency: (value) ->
	if value is '' or not value? or isNaN value
		num = 0.00
	else
		num = value / 100
	parseFloat(num).toFixed(2).replace('.', ',').toString().replace(/(\d)(?=(\d\d\d)+(?!\d))/g, '$1.')


#
# Plugin
#
$.fn.vtexMinicart = (options) ->
	@each ->
		return 'ja tem' if $.data(this, "plugin_vtexMinicart")
		$.data(@, "plugin_vtexMinicart", new vtexMinicart(@, options))
	return this

$.fn.vtexMinicart.defaults =
	timeoutToHide: null
	cartData: null
	$template: null


$ -> $('.portal-minicart-ref').vtexMinicart()
# $ -> $('#vtex-minicart').vtexMinicart()