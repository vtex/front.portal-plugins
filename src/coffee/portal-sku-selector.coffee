# DEPENDENCIES:
# jQuery
# vtex-utils

$ = window.jQuery

#
# CLASSES
#
class SkuSelector
	constructor: (productData) ->
		@productId = productData.productId
		@name = productData.name
		@salesChannel = productData.salesChannel
		@skus = productData.skus

		i = 0
		@dimensions = ({
		index: i++
		name: dimensionName
		nameClass: ""
		values: productData.dimensionsMap[dimensionName]
		availableValues: (true for value in productData.dimensionsMap[dimensionName])
		validValues: (true for value in productData.dimensionsMap[dimensionName])
		selected: undefined
		inputType: productData.dimensionsInputType?[dimensionName]?.toLowerCase() || "radio"
		} for dimensionName in productData.dimensions)
		dim.radio = (dim.inputType == "radio") for dim in @dimensions
		dim.combo = (dim.inputType == "combo") for dim in @dimensions

		sku.values = (sku.dimensions[dim.name] for dim in @dimensions) for sku in @skus

	update: (dimensionName, dimensionValue) =>
		@setSelectedDimension(dimensionName, dimensionValue) if dimensionName

		while @isSelectedInexistent()
			@unselectLast(dimensionName)

		if (skus = @findSelectableSkus()).length == 1
			sku = skus[0]
			@selectSku(sku)

	isSelectedInexistent: =>
		@findSelectableSkus().length == 0

	unselectLast: (exceptDimension) =>
		for dim in @dimensions by -1
			if dim.selected isnt undefined and dim.name isnt exceptDimension
				dim.selected = undefined
				return true
		return false

	isSkuSelectable: (sku) =>
		for dimension in @dimensions when dimension.selected isnt undefined
			if dimension.selected isnt sku.dimensions[dimension.name]
				return false
		return true

	findSelectableSkus: =>
		(sku for sku in @skus when @isSkuSelectable(sku))

	findPrices: (skus = undefined) =>
		skus or= @findSelectableSkus()
		$.map(skus, (sku) -> sku.bestPrice).sort( (a,b) -> return parseInt(a) - parseInt(b) )

	searchDimensions: (fn = ()->true) =>
		$.grep(@dimensions, fn)

	getDimensionByName: (dimensionName) =>
		@searchDimensions((dim) -> dim.name == dimensionName)[0]

	getSelectedDimension: (dimension) =>
		@getDimensionByName(dimension).selected

	setSelectedDimension: (dimension, value) =>
		@getDimensionByName(dimension).selected = value

	selectSku: (sku) =>
		for dimension in @dimensions
			dimension.selected = sku.dimensions[dimension.name]

	findSelectionStatus: (selection) =>
		foundUnavailable = false
		for sku in @skus
			if @skuMatches(sku, selection)
				if sku.available
					return "ok"
				else
					foundUnavailable = true
		return "unavailable" if foundUnavailable
		return "invalid"

	skuMatches: (sku, selection) =>
		for value, i in sku.values
			if selection[i] isnt undefined and selection[i] isnt value
				return false
		return true


class SkuSelectorRenderer
	constructor: (context, options, data) ->
		@context = context
		@options = options

		#SkuSelector
		@data = data
		@data.image = @data.skus[0].image

		# Build selectors from given select strings.
		@select = _.mapObj options.selectors, (key, val) =>
			( => $(val, @context) )

		@select.inputs = => $('input, select', @context)
		@select.itemDimension = (dimensionName) => $(".item-dimension-#{_.sanitize(dimensionName)}", @context)
		@select.itemDimensionInput = (dimensionName) =>	@select.itemDimension(dimensionName).find('input')
		@select.itemDimensionLabel = (dimensionName) =>	@select.itemDimension(dimensionName).find('label')
		@select.itemDimensionOption = (dimensionName) => @select.itemDimension(dimensionName).find('option')
		@select.itemDimensionValueInput = (dimensionName, valueName) =>	@select.itemDimension(dimensionName).find("input[value='#{valueName}']")
		@select.itemDimensionValueLabel = (dimensionName, valueName) =>	@select.itemDimension(dimensionName).find("label.skuespec_#{_.sanitize(valueName)}")
		@select.itemDimensionValueOption = (dimensionName, valueName) => @select.itemDimension(dimensionName).find("option[value='#{valueName}']")


	# Renders the DOM elements of the Sku Selector
	render: =>
		dust.render "sku-selector", @data, (err, out) =>
			console.log err if err
			@context.html out

	update: =>
		originalSelection = (dim.selected for dim in @data.dimensions)

		for dimension, i in @data.dimensions
			@resetDimension(dimension)
			@selectValue(dimension)

			for value in dimension.values
				selection = originalSelection.slice(0)
				selection[i] = value
				switch @data.findSelectionStatus(selection)
					when "invalid"
						@disableInvalidValue(dimension, value)
					when "unavailable"
						@disableUnavailableValue(dimension, value)

		selectableSkus = @data.findSelectableSkus()

		@hideBuyButton()
		@hideConfirmButton()
		@hideWarnUnavailable()
		@hidePriceRange()
		@hidePrice()

		if selectableSkus.length == 1
			selectedSku = selectableSkus[0]
			if selectedSku.available
				@showBuyButton(selectedSku)
				@showPrice(selectedSku)
			else
				@context.trigger 'skuSelected', [selectedSku]
				if @options.warnUnavailable
					@showWarnUnavailable(selectedSku)
		else if selectableSkus.length > 0
			@showPriceRange(@data.findPrices(selectableSkus))

	resetDimension: (dimension) =>
		@select.itemDimensionInput(dimension.name)
		.removeAttr('checked')
		.removeAttr('disabled')
		.removeClass('item_unavaliable sku-picked checked item_unavailable ')

		@select.itemDimensionLabel(dimension.name)
		.removeClass('item_unavaliable sku-picked checked item_unavailable disabled')

		@select.itemDimensionOption(dimension.name)
		.removeClass('item_unavaliable sku-picked checked item_unavailable ')
		.removeAttr('disabled')
		.removeAttr('selected')

	selectValue: (dimension) =>
		value = dimension.selected

		if value is undefined
			@select.itemDimensionInput(dimension.name)
			.removeAttr('checked')
			@select.itemDimensionOption(dimension.name)
			.removeAttr('selected')
			@select.itemDimensionValueOption(dimension.name, "")
			.attr('selected', 'selected')
		else
			@select.itemDimensionValueInput(dimension.name, value)
			.attr('checked', 'checked')
			.addClass('checked sku-picked')
			@select.itemDimensionValueLabel(dimension.name, value)
			.addClass('checked sku-picked')
			@select.itemDimensionValueOption(dimension.name, value)
			.attr('selected', 'selected')
			.addClass('checked sku-picked')

	disableInvalidValue: (dimension, value) =>
		@select.itemDimensionValueInput(dimension.name, value)
		.addClass('disabled')
		@select.itemDimensionValueLabel(dimension.name, value)
		.addClass('disabled')
		@select.itemDimensionValueOption(dimension.name, value)
		.addClass('disabled')

	disableUnavailableValue: (dimension, value) =>
		@select.itemDimensionValueInput(dimension.name, value)
		.addClass('item_unavaliable item_unavailable')
		@select.itemDimensionValueLabel(dimension.name, value)
		.addClass('item_unavaliable item_unavailable')
		@select.itemDimensionValueOption(dimension.name, value)
		.addClass('item_unavaliable item_unavailable')

	hideBuyButton: =>
		@select.buyButton().attr('href', 'javascript:void(0);').hide()

	hideConfirmButton: =>
		@select.confirmButton().attr('href', 'javascript:void(0);').hide()

	hidePrice: =>
		@select.price().hide()

	hidePriceRange: =>
		@select.priceRange().hide()

	hideWarnUnavailable: =>
		@select.warning().hide()
		@select.warnUnavailable().filter(':visible').hide()

	showBuyButton: (sku) =>
		@select.buyButton().attr('href', $.skuSelector.getAddUrlForSku(sku.sku, sku.sellerId, 1, @data.salesChannel)).show()

	showConfirmButton: (sku) =>
		dimensionsText = $.map(sku.dimensions, (k, v) -> k).join(', ')

		@select.confirmButton()
		.attr('href', $.skuSelector.getAddUrlForSku(sku.sku, sku.sellerId, 1, @data.salesChannel))
		.show()
		.find('.skuselector-confirm-dimensions').text(dimensionsText)

	showPrice: (sku) =>
		listPrice = _.formatCurrency sku.listPrice/100
		bestPrice = _.formatCurrency sku.bestPrice/100
		installments = sku.installments
		installmentValue = _.formatCurrency sku.installmentsValue/100

		@select.listPriceValue().text("R$ #{listPrice}")
		@select.bestPriceValue().text("R$ #{bestPrice}")
		if installments > 1
			@select.installment().text("ou até #{installments}x de R$ #{installmentValue}")

		@select.price().show()

	showPriceRange: (prices) =>
		$priceRange = @select.priceRange().show()
		min = _.formatCurrency prices[0]/100
		max = _.formatCurrency prices[prices.length-1]/100
		$priceRange.find('.lowPrice').text(" R$ #{min} ")
		$priceRange.find('.highPrice').text(" R$ #{max} ")

	showWarnUnavailable: (sku) =>
		@select.warnUnavailable().show().find('input#notifymeSkuId').val(sku)

#
# PLUGIN ENTRY POINT
#
$.fn.skuSelector = (productData, jsOptions = {}) ->
	this.addClass('sku-selector-loading')
	context = this

	# Gather options
	domOptions = this.data()
	defaultOptions = $.fn.skuSelector.defaults
	# Build final options object (priority: js, then dom, then default)
	# Deep extending with true, for the selectors
	options = $.extend(true, defaultOptions, domOptions, jsOptions)

	# Instantiate our singletons
	selector = new SkuSelector(productData)
	renderer = new SkuSelectorRenderer(this, options, selector)

	selector.update()
	# Finds elements and puts SKU information in them
	renderer.render()
	renderer.update()

	# Handler for the buy button
	buyButtonHandler = (event) =>
		selectedSku = selector.findSelectedSku()
		if selectedSku
			if options.confirmBuy
				event.preventDefault()
				renderer.showConfirmButton(selectedSku)
			else
				return options.addSkuToCart(selectedSku.sku, context)
		else
			renderer.select.warning().show().text('Por favor, escolha: ' + selector.findUndefinedDimensions()[0].name)
			return false

	# Handles changes in the dimension inputs
	dimensionChangeHandler = (event) ->
		$this = $(this)

		# Collect info
		dimensionName = $this.data('dimension')
		dimensionValue = if $this.val() is "" then undefined else $this.val()

		# Process data
		selector.update(dimensionName, dimensionValue)

		# Update DOM
		renderer.update()

		selectableSkus = selector.findSelectableSkus()
		# Trigger event for interested scripts
		$this.trigger 'vtex.sku.dimensionChanged', [dimensionName, dimensionValue]
		if selectableSkus.length == 1
			$this.trigger 'vtex.sku.selected', [selectableSkus[0]]


	# Handles submission in the warn unavailable form
	warnUnavailableSubmitHandler = (e) ->
		renderer.select.warnUnavailable().find('#notifymeLoading').show()
		renderer.select.warnUnavailable().find('form').hide()
		return false


	# Binds handlers
	renderer.select.buyButton()
	.on 'click', buyButtonHandler

	renderer.select.inputs()
	.on('change', dimensionChangeHandler)

	if options.warnUnavailable
		renderer.select.warnUnavailable().find('form')
		.on 'submit', warnUnavailableSubmitHandler

	# Select first dimension
	#	if options.selectOnOpening or selector.findSelectedSku()
	#		renderer.selectDimension(selector.dimensions[0])

	$(window).trigger('vtex.sku.ready')
	this.removeClass('sku-selector-loading')

	# Chaining
	return this


#
# LIQUID HELPERS
#
_.extend dust.filters,
	sanitize: (value) -> _.sanitize value
	spacesToHyphens: (value) -> _.spacesToHyphens value

#
# PLUGIN DEFAULTS
#
$.fn.skuSelector.defaults =
	warnUnavailable: false
	selectOnOpening: false
	confirmBuy: false
	priceRange: false
	selectors:
		listPriceValue: '.skuselector-list-price .value'
		bestPriceValue: '.skuselector-best-price .value'
		installment: '.skuselector-installment'
		buyButton: '.skuselector-buy-btn'
		confirmButton: '.skuselector-confirm-btn'
		price: '.skuselector-price'
		priceRange: '.skuselector-price-range'
		warning: '.skuselector-warning'
		warnUnavailable: '.skuselector-warn-unavailable'

# Called when we failed to receive variations.
	skuVariationsFailHandler: ($el, options, reason) ->
		$el.removeClass('sku-selector-loading')
		window.location.href = options.productUrl if options.productUrl

	warnUnavailablePost: (formElement) ->
		$.post '/no-cache/AviseMe.aspx', $(formElement).serialize()


#
# PLUGIN SHARED FUNCTIONS
#

$.skuSelector = {}

# Given a product id, return a promise for a request for the sku variations
$.skuSelector.getSkusForProduct = (productId) ->
	$.get '/api/catalog_system/pub/products/variations/' + productId

$.skuSelector.getAddUrlForSku = (sku, seller = 1, qty = 1, salesChannel = 1, redirect = true) ->
	"/checkout/cart/add?qty=#{qty}&seller=#{seller}&sku=#{sku}&sc=#{salesChannel}&redirect=#{redirect}"


#
# EXPORTS
#
window.vtex or= {}
vtex.portalPlugins or= {}
vtex.portalPlugins.SkuSelector = SkuSelector
vtex.portalPlugins.SkuSelectorRenderer = SkuSelectorRenderer


#
# EVENTS
#
$(document).on "vtex.sku.selected", (evt, sku) ->
	window.FireSkuChangeImage?(sku.sku)
	#window.FireSkuDataReceived?(sku.sku)
	window.FireSkuSelectionChanged?(sku.sku)
