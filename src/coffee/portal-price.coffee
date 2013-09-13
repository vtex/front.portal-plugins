# DEPENDENCIES:
# jQuery
# Dust
# vtex.utils

$ = window.jQuery


# DUST FILTERS
_.extend dust.filters,
	intAsCurrency: (value) -> _.intAsCurrency value

# CLASSES
class Price extends ProductComponent
	constructor: (@element, @productId, @options) ->
		@originalHTML = @element.html()
		@sku = null
		@init()

	init: =>
		@render()
		@bindEvents()

	render: =>
		if @sku or @options.fallback is 'sku'
			renderData =
				product: @sku or @originalSku
				accessories: @getAccessoriesTotal()
				total: @getTotal()

			dust.render 'price', renderData, (err, out) =>
				throw new Error "Price Dust error: #{err}" if err
				@element.html out
				@update()
		else
			@element.html @originalHTML

	update: =>
		@hideAll()
		if @sku.available
				@showBestPrice()

				if @sku.bestPrice? and @sku.bestPrice < @sku.listPrice
					@showListPrice()
					@showSavings()
				
				if @sku.installments? and @sku.installments > 1
					@showInstallments()

	findBestPrice: => @element.find('.price-best-price')
	hideBestPrice: => @findBestPrice().hide()
	showBestPrice: => @findBestPrice().show()
	findListPrice: => @element.find('.price-list-price')
	hideListPrice: => @findListPrice().hide()
	showListPrice: => @findListPrice().show()
	findSavings: => @element.find('.price-savings')
	hideSavings: => @findSavings().hide()
	showSavings: => @findSavings().show()
	findInstallments: => @element.find('.price-installments')
	hideInstallments: => @findInstallments().hide()
	showInstallments: => @findInstallments().show()

	hideAll: =>
		@hideBestPrice()
		@hideListPrice()
		@hideSavings()
		@hideInstallments()

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
				listPrice: @sku.listPrice or @originalSku.listPrice
				bestPrice: @sku.bestPrice or @originalSku.bestPrice

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
	fallback: 'html'
	originalSku: null