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
		@skus = productData.skus

		i = 0
		@dimensions = ({
		index: i++
		name: dimensionName
		nameClass: "item-dimension-#{_.sanitize(dimensionName)}"
		values: productData.dimensionsMap[dimensionName]
		availableValues: (true for value in productData.dimensionsMap[dimensionName])
		validValues: (true for value in productData.dimensionsMap[dimensionName])
		selected: undefined
		inputType: productData.dimensionsInputType?[dimensionName]?.toLowerCase() || "radio"
		} for dimensionName in productData.dimensions)
		dim.radio = (dim.inputType == "radio") for dim in @dimensions
		dim.combo = (dim.inputType == "combo") for dim in @dimensions

	findUndefinedDimensions: =>
		(dim for dim in @dimensions when dim.selected is undefined)

	findAvailableSkus: =>
		(sku for sku in @skus when sku.available)

	isSkuSelectable: (sku) =>
		for dimension in @dimensions when dimension.selected isnt undefined
			if dimension.selected isnt sku.dimensions[dimension.name]
				return false
		return true

	findSelectableSkus: =>
		(sku for sku in @skus when @isSkuSelectable(sku))

	findSelectedSku: (skus = undefined) =>
		skus or= @findSelectableSkus()
		return if skus.length is 1 then skus[0] else undefined

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

	smartUpdate: (dimensionName) =>
		dimension = @getDimensionByName(dimensionName) if dimensionName
		selectedSku = @findSelectedSku()

		#		@updateValidValues()
		@resetNextDimensions(dimensionName) if dimensionName
		@unselectInvalidValues()
		@updateValidValues()
		if selectedSku
			unless dimension?.selected is undefined
				@selectSku(selectedSku)

	resetNextDimensions: (dimensionName) =>
		currentIndex = @getDimensionByName(dimensionName).index
		dim.selected = undefined for dim in @searchDimensions((dim) -> dim.index > currentIndex)

	selectSku: (sku) =>
		for dimension in @dimensions
			dimension.selected = sku.dimensions[dimension.name]

	updateValidValues: =>
		selectableSkus = @findSelectableSkus()
		undefinedDimensions = @findUndefinedDimensions()

		for dimension in undefinedDimensions
			dimension.validValues = dimension.validValues.map( -> false )
			dimension.availableValues = dimension.availableValues.map( -> false )

			for value, i in dimension.values
				for sku in selectableSkus
					if sku.dimensions[dimension.name] is value
						dimension.validValues[i] = true
						if sku.available
							dimension.availableValues[i] = true

	unselectInvalidValues: =>
		for dimension in @dimensions
			unless dimension.validValues[ dimension.values.indexOf(dimension.selectedValue) ]
				dimension.selectedValue = undefined


class SkuSelectorRenderer
	constructor: (context, options, data) ->
		@context = context
		@options = options

		@template = Handlebars.compile(@context.html())

		#SkuSelector
		@data = data

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
	render: (selector) =>
		@context.html(@template(@data))

	smartUpdate: =>
		for dimension in @data.dimensions
			@resetDimension(dimension)
			@selectValue(dimension)

			for value, i in dimension.values
				unless dimension.validValues[i]
					@disableInvalidValue(dimension, value)
				unless dimension.availableValues[i]
					@disableUnavailableValue(dimension, value)

		selectableSkus = @data.findSelectableSkus()
		selectedSku = @data.findSelectedSku(selectableSkus)

		@hideBuyButton()
		@hideConfirmButton()
		@hideWarnUnavailable()
		@hidePriceRange()
		@hidePrice()

		if selectedSku
			if selectedSku.available
				@showBuyButton(selectedSku)
				@showPrice(selectedSku)
			else if @options.warnUnavailable
				@showWarnUnavailable(selectedSku)
		else if selectableSkus.length > 0
			@showPriceRange(@data.findPrices(selectableSkus))

	resetDimension: (dimension) =>
		@select.itemDimensionInput(dimension.name)
		.removeAttr('checked')
		.removeAttr('disabled')
		.removeClass('checked sku-picked item_unavaliable')

		@select.itemDimensionLabel(dimension.name)
		.removeClass('item_unavaliable disabled')

		@select.itemDimensionOption(dimension.name)
		.removeClass('checked sku-picked item_unavaliable')
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
			@select.itemDimensionValueOption(dimension.name, value)
			.attr('selected', 'selected')
			.addClass('checked sku-picked')

	disableInvalidValue: (dimension, value) =>
		@select.itemDimensionValueInput(dimension.name, value)
		.attr('disabled', 'disabled')
		@select.itemDimensionValueOption(dimension.name, value)
		.attr('disabled', 'disabled')

	disableUnavailableValue: (dimension, value) =>
		@select.itemDimensionValueInput(dimension.name, value)
		.addClass('item_unavaliable')
		@select.itemDimensionValueLabel(dimension.name, value)
		.addClass('item_unavaliable disabled')

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
		@select.buyButton().attr('href', $.skuSelector.getAddUrlForSku(sku.sku, sku.sellerId)).show()

	showConfirmButton: (sku) =>
		dimensionsText = $.map(sku.dimensions, (k, v) -> k).join(', ')

		@select.confirmButton()
		.attr('href', $.skuSelector.getAddUrlForSku(sku.sku, sku.sellerId))
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
		$priceRange.find('.lowPrice').text("R$ #{prices[0]}")
		$priceRange.find('.highPrice').text("R$ #{prices[prices.length-1]}")

	showWarnUnavailable: (sku) =>
		@select.warnUnavailable().find('input#notifymeSkuId').val(sku).show()

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

	selector.smartUpdate()

	# Finds elements and puts SKU information in them
	renderer.render()
	renderer.smartUpdate()

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

		# Update data
		selector.setSelectedDimension(dimensionName, dimensionValue)

		# Process data
		selector.smartUpdate(dimensionName)

		# Update DOM
		renderer.smartUpdate()

		selectedSku = selector.findSelectedSku()
		# Trigger event for interested scripts
		$this.trigger 'dimensionChanged', [dimensionName, dimensionValue]
		if selectedSku
			$this.trigger 'skuSelected', [selectedSku]


	# Handles submission in the warn unavailable form
	warnUnavailableSubmitHandler = (e) ->
		renderer.select.warnUnavailable().find('#notifymeLoading').show()
		renderer.select.warnUnavailable().find('form').hide()
		return false


	# Binds handlers
	renderer.select.buyButton()
	.on 'click', buyButtonHandler

	renderer.select.inputs()
	.on 'change', dimensionChangeHandler

	if options.warnUnavailable
		renderer.select.warnUnavailable().find('form')
		.on 'submit', warnUnavailableSubmitHandler

	# Select first dimension
	#	if options.selectOnOpening or selector.findSelectedSku()
	#		renderer.selectDimension(selector.dimensions[0])

	$(window).trigger('skuSelectorReady')
	this.removeClass('sku-selector-loading')

	# Chaining
	return this


#
# HANDLEBARS HELPERS
#
Handlebars.registerHelper('sanitize', (text) -> new Handlebars.SafeString _.sanitize text)
Handlebars.registerHelper('spacesToHyphens', (text) -> new Handlebars.SafeString _.spacesToHyphens text)

#
# PLUGIN DEFAULTS
#
$.fn.skuSelector.defaults =
	warnUnavailable: true
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

$.skuSelector.getAddUrlForSku = (sku, seller = 1, qty = 1, redirect = true) ->
	window.location.protocol + '//' + window.location.host + "/checkout/cart/add?qty=#{qty}&seller=#{seller}&sku=#{sku}&redirect=#{redirect}"


#
# EXPORTS
#
window.vtex or= {}
vtex.portalPlugins or= {}
vtex.portalPlugins.SkuSelector = SkuSelector
vtex.portalPlugins.SkuSelectorRenderer = SkuSelectorRenderer