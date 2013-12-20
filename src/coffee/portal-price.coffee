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
			OriginalBestPrice: '.valor-por span'
			OriginalInstallments: '.valor-dividido span span label'
			OriginalInstallmentsValue: '.skuBestInstallmentValue'

		unless @options.modalLayout
			htmlDe = $('.valor-de').clone()
			htmlDe.find('strong').remove()
			@de = htmlDe.text() or 'De: '
			htmlPor = $('.valor-por').clone()
			htmlPor.find('strong').remove()
			@por = htmlPor.text() or 'Por: '

		@bindEvents()

	getSku: =>
		@sku or {
			listPrice: _.currencyToInt(@findFirstOriginalListPrice().text())
			bestPrice: _.currencyToInt(@findFirstOriginalBestPrice().text())
			installments: @findFirstOriginalInstallments().text()
			installmentsValue: _.currencyToInt(@findFirstOriginalInstallmentsValue().text())
			available: true
		}

	render: =>
		if @options.modalLayout
			dust.render 'price-modal', {product: @sku}, (err, out) =>
				throw new Error "Price-modal Dust error: #{err}" if err
				@element.html out
				@update()

		else
			renderData =
				product: @getSku()
				accessories: @getAccessoriesTotal()
				total: @getTotal()
				de: @de
				por: @por

			if renderData.product is null or renderData.product.listPrice is 0 or renderData.product.bestPrice is 0
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
		@bindProductEvent 'vtex.sku.selected', @skuSelected
		@bindProductEvent 'vtex.sku.unselected', @skuUnselected
		@bindProductEvent 'vtex.accessories.updated', @accessoriesUpdated

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
