# DEPENDENCIES:
# jQuery
# Dust
# vtex.utils

$ = window.jQuery


# DUST FILTERS
_.extend dust.filters,
	intAsCurrency: (value) -> _.intAsCurrency value

_.currencyToInt = (text) ->
	+text.replace(/\D/gi, '')


# CLASSES
class Price extends ProductComponent
	constructor: (@element, @productId, @options) ->
		@sku = null

		@generateSelectors
			ListPrice: '.price-list-price'
			BestPrice: '.price-best-price'
			Savings: '.price-savings'
			Installments: '.price-installments'
			CashPrice: '.price-cash'
			OriginalListPrice: '.skuListPrice'
			OriginalBestPrice: '.skuBestPrice'
			OriginalInstallments: '.skuBestInstallmentNumber'
			OriginalInstallmentsValue: '.skuBestInstallmentValue'

		unless @options.modalLayout
			@getDefaultStringsFromHtml()

		@bindEvents()

	getDefaultStringsFromHtml: =>
		htmlDe = $($('.valor-de')[0]).clone()
		htmlDe.find('strong').remove()
		@options.strings.listPrice = htmlDe.text() or 'De: '
		htmlPor = $($('.valor-por')[0]).clone()
		htmlPor.find('strong').remove()
		@options.strings.bestPrice = htmlPor.text() or 'Por: '

	getSku: =>
		base = @sku or
			listPrice: _.currencyToInt(@findFirstOriginalListPrice().text())
			bestPrice: _.currencyToInt(@findFirstOriginalBestPrice().text())
			installments: parseInt(@findFirstOriginalInstallments().text())
			installmentsValue: _.currencyToInt(@findFirstOriginalInstallmentsValue().text())
			available: true

		base.hasDiscount = !!base.bestPrice && (base.discount = base.listPrice - base.bestPrice) > 0
		base.validListPrice = !!base.listPrice && base.listPrice > base.bestPrice
		base.validBestPrice = !!base.bestPrice
		return base

	render: =>
		if @options.modalLayout
			dust.render 'price-modal', {product: @sku, strings: @options.strings}, (err, out) =>
				throw new Error "Price-modal Dust error: #{err}" if err
				@element.html out
				@update()

		else
			renderData =
				product: @getSku()
				accessories: @getAccessoriesTotal()
				total: @getTotal()
				strings: @options.strings

			if renderData.product is null or (renderData.product.listPrice is 0 and renderData.product.bestPrice is 0)
				return

			dust.render 'price', renderData, (err, out) =>
				throw new Error "Price Dust error: #{err}" if err
				@element.html out
				@update()

	hideAllPrice: =>
		@hideBestPrice()
		@hideListPrice()
		@hideSavings()
		@hideCashPrice()
		@hideInstallments()

	update: =>
		@hideAllPrice()
		sku = @getSku()

		if sku.available
			@showBestPrice()

			if sku.bestPrice? and sku.bestPrice < sku.listPrice
				@showListPrice()
				@showSavings()

			if sku.installments? and sku.installments > 1
				@showInstallments()
				@showCashPrice()

	bindEvents: =>
		@bindProductEvent 'skuSelected.vtex', @skuSelected
		@bindProductEvent 'skuUnselected.vtex', @skuUnselected
		@bindProductEvent 'accessoriesUpdated.vtex', @accessoriesUpdated

	skuSelected: (evt, productId, sku) =>
		@sku = sku
		@render()

	skuUnselected: (evt, productId, selectableSkus) =>
		@sku = null
		@render()

	accessoriesUpdated: (evt, productId, accessories) =>
		@accessories = accessories
		@render()

	getAccessoriesTotal: =>
		if @accessories?.length
			total =
				listPrice: 0
				bestPrice: 0

			for a in @accessories when a.quantity > 0
				total.listPrice += a.listPrice
				total.bestPrice += a.bestPrice

			return total

	getTotal: =>
		if @accessories?.length
			total =
				listPrice: @getSku().listPrice
				bestPrice: @getSku().bestPrice

			for a in @accessories when a.quantity > 0
				total.listPrice += a.listPrice
				total.bestPrice += a.bestPrice

			return total


# PLUGIN ENTRY POINT
$.fn.price = (productId, jsOptions) ->
	defaultOptions = $.extend {}, $.fn.price.defaults
	for element in this
		$element = $(element)
		domOptions = $element.data()
		options = $.extend(true, defaultOptions, domOptions, jsOptions)
		unless $element.data('price')
			$element.data('price', new Price($element, productId, options))

	return this


# PLUGIN DEFAULTS
$.fn.price.defaults =
	originalSku: null
	modalLayout: false
	strings:
		listPrice: 'De: '
		bestPrice: 'Por: '
		discountOf: 'Economia de '
