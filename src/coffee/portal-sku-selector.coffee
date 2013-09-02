# DEPENDENCIES:
# jQuery
# vtex-utils
# dust

$ = window.jQuery

# DUST FILTERS
_.extend dust.filters,
	sanitize: (value) -> _.sanitize value
	spacesToHyphens: (value) -> _.spacesToHyphens value


# CLASSES
class SkuSelector
	constructor: (@productData, @options) ->
		@productId = @productData.productId
		@name = @productData.name
		@salesChannel = @productData.salesChannel
		@skus = @productData.skus

		i = 0
		@dimensions = ({
			index: i++
			name: dimensionName
			values: @productData.dimensionsMap[dimensionName]
			availableValues: (true for value in @productData.dimensionsMap[dimensionName])
			validValues: (true for value in @productData.dimensionsMap[dimensionName])
			selected: undefined
			inputType: @productData.dimensionsInputType?[dimensionName]?.toLowerCase() || "radio"
		} for dimensionName in @productData.dimensions)
		dim.isRadio = (dim.inputType == "radio") for dim in @dimensions
		dim.isCombo = (dim.inputType == "combo") for dim in @dimensions

		sku.values = (sku.dimensions[dim.name] for dim in @dimensions) for sku in @skus

		@init()

	init: =>
		@update()

		if @options.selectOnOpening
			for sku in @skus
				if sku.available
					@selectSku(sku)
					break

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

	findSelectedSku: =>
		all = @findSelectableSkus()
		if all.length is 1
			return all[0]
		else
			return null

	findPrices: (skus = undefined) =>
		skus or= @findSelectableSkus()
		skus = (sku for sku in skus when sku.available)
		$.map(skus, (sku) -> sku.bestPrice).sort( (a,b) -> return parseInt(a) - parseInt(b) )

	searchDimensions: (fn = ()->true) =>
		$.grep(@dimensions, fn)

	getDimensionByName: (dimensionName) =>
		@searchDimensions((dim) -> dim.name == dimensionName)[0]

	findUndefinedDimensions: =>
		@searchDimensions((dim) -> !dim.selected)

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
	constructor: (@context, @options, @data) ->
		#SkuSelector
		@data.image = @data.skus[0].image

		# Build selectors from given select strings.
		@select = _.mapObj $.skuSelector.selectors, (key, val) =>
			( => $(val, @context) )

		@select.inputs = => $('input, select', @context)
		@select.itemDimension = (dimensionName) => $(".item-dimension-#{_.sanitize(dimensionName)}", @context)
		@select.itemDimensionInput = (dimensionName) =>	@select.itemDimension(dimensionName).find('input')
		@select.itemDimensionLabel = (dimensionName) =>	@select.itemDimension(dimensionName).find('label')
		@select.itemDimensionOption = (dimensionName) => @select.itemDimension(dimensionName).find('option')
		@select.itemDimensionValueInput = (dimensionName, valueName) =>	@select.itemDimension(dimensionName).find("input[value='#{valueName}']")
		@select.itemDimensionValueLabel = (dimensionName, valueName) =>	@select.itemDimension(dimensionName).find("label.skuespec_#{_.sanitize(valueName)}")
		@select.itemDimensionValueOption = (dimensionName, valueName) => @select.itemDimension(dimensionName).find("option[value='#{valueName}']")

		@init()

	init: =>
		@update()
		@render()

	# Renders the DOM elements of the Sku Selector
	render: =>
		templateName = if @options.modalLayout then 'sku-selector-modal' else 'sku-selector-product'
		dust.render templateName, @data, (err, out) =>
			console.log "Sku Selector Dust error: ", err if err
			@context.html out
			@update()
			@showBuyButton()
			@buyIfNoVariations()
			@context.trigger('vtex.sku.ready')

	buyIfNoVariations: =>
		# ToDo: NOJENTO
		if @data.skus.length < 2 and @options.modalLayout
			console.log 'nojo'
			setTimeout (=> @select.buyButton().click()), 1

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

		@hideConfirmButton()
		@hideWarnUnavailable()
		@hidePriceRange()
		@hidePrice()

		if selectableSkus.length == 1
			selectedSku = selectableSkus[0]
			@context.trigger 'skuSelected', [selectedSku]
			if selectedSku.available
				@showBuyButton(selectedSku)
				@showPrice(selectedSku)
			else
				@showWarnUnavailable(selectedSku.sku) if @options.warnUnavailable
				@hideBuyButton()
		else if selectableSkus.length > 1 and @options.showPriceRange
			@showPriceRange(@data.findPrices(selectableSkus))

	resetDimension: (dimension) =>
		@select.itemDimensionInput(dimension.name)
		.removeAttr('checked')
		.removeAttr('disabled')
		.removeClass('item_unavaliable sku-picked checked item_unavailable item_doesnt_exist')

		@select.itemDimensionLabel(dimension.name)
		.removeClass('item_unavaliable sku-picked checked item_unavailable disabled item_doesnt_exist')

		@select.itemDimensionOption(dimension.name)
		.removeClass('item_unavaliable sku-picked checked item_unavailable disabled item_doesnt_exist')
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
		.addClass('item_doesnt_exist')
		@select.itemDimensionValueLabel(dimension.name, value)
		.addClass('item_doesnt_exist')
		@select.itemDimensionValueOption(dimension.name, value)
		.addClass('item_doesnt_exist')

	disableUnavailableValue: (dimension, value) =>
		@select.itemDimensionValueInput(dimension.name, value)
		.addClass('item_unavaliable item_unavailable')
		@select.itemDimensionValueLabel(dimension.name, value)
		.addClass('item_unavaliable item_unavailable disabled')
		@select.itemDimensionValueOption(dimension.name, value)
		.addClass('item_unavaliable item_unavailable disabled')

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
		@select.buyButton().show().parent().show()
		@select.buyButton().attr('href', $.skuSelector.getAddUrlForSku(sku.sku, sku.sellerId, 1, @data.salesChannel, @options.redirect)) if sku

	showConfirmButton: (sku) =>
		dimensionsText = $.map(sku.dimensions, (k, v) -> k).join(', ')

		@select.confirmButton()
		.attr('href', $.skuSelector.getAddUrlForSku(sku.sku, sku.sellerId, 1, @data.salesChannel, @options.redirect))
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
		@select.warnUnavailable().show().find('input.sku-notifyme-skuid').val(sku)


# PLUGIN ENTRY POINT
$.fn.skuSelector = (productData, jsOptions = {}) ->
	if this.length > 1
		throw new Error('Sku Selector should be activated on only one element! To activate many sku selectors, activate it for each element.')
	else if this.length == 0
		throw new Error('Sku Selector was activated on 0 elements')

	this.addClass('sku-selector-loading')
	context = $(this)

	# Gather options
	domOptions = this.data()
	defaultOptions = $.extend({}, $.fn.skuSelector.defaults)
	# Build final options object (priority: js, then dom, then default)
	# Deep extending with true, for the selectors
	options = $.extend(true, defaultOptions, domOptions, jsOptions)

	# Instantiate our singletons
	selector = new SkuSelector(productData, options)
	renderer = new SkuSelectorRenderer(this, options, selector)

	context.data('skuSelector', selector)
	context.data('skuSelectorRenderer', renderer)

	# Handler for the buy button
	buyButtonHandler = (event) ->
		selectedSku = selector.findSelectedSku()
		if selectedSku
			if options.confirmBuy
				event.preventDefault()
				renderer.showConfirmButton(selectedSku)
			else
				context.trigger 'vtex.modal.hide'
				# console.log 'Adding SKU to cart:', sku
				$.get($.skuSelector.getAddUrlForSku(selectedSku.sku, 1, 1, productData.salesChannel, false))
				.done (data) ->
					$(window).trigger 'productAddedToCart'
				.fail (jqXHR, status) ->
					window.location.href = $.skuSelector.getAddUrlForSku(selectedSku.sku, 1, productData.salesChannel)
				return false
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
		$this.trigger 'vtex.sku.dimensionChanged', [dimensionName, dimensionValue, productData.productId]
		if selectableSkus.length == 1
			$this.trigger 'vtex.sku.selected', [selectableSkus[0], productData.productId]
			$this.trigger 'skuSelected', [selectableSkus[0], productData.productId]
		else
			$this.trigger 'vtex.sku.unselected', [selectableSkus, productData.productId]


	# Handles submission in the warn unavailable form
	warnUnavailableSubmitHandler = (e) ->
		e.preventDefault()
		renderer.select.warnUnavailable().find('.sku-notifyme-loading').show()
		renderer.select.warnUnavailable().find('form').hide()
		xhr = options.warnUnavailablePost(e.target)
		xhr.done -> renderer.select.warnUnavailable().find('.sku-notifyme-success').show()
		xhr.fail -> renderer.select.warnUnavailable().find('.sku-notifyme-loading-error').show()
		xhr.always -> renderer.select.warnUnavailable().find('.sku-notifyme-loading').hide()
		return false


	# Binds handlers
	renderer.select.buyButton()
	.on 'click', buyButtonHandler

	renderer.select.inputs()
	.on('change', dimensionChangeHandler)

	if options.warnUnavailable
		renderer.select.warnUnavailable().find('form')
		.on('submit', warnUnavailableSubmitHandler)

	this.removeClass('sku-selector-loading')

	# Chaining
	return this


# PLUGIN DEFAULTS
$.fn.skuSelector.defaults =
	modalLayout: false
	warnUnavailable: false
	selectOnOpening: false
	confirmBuy: false
	showPriceRange: false

# Called when we failed to receive variations.
	skuVariationsFailHandler: ($el, options, reason) ->
		$el.removeClass('sku-selector-loading')
		window.location.href = options.productUrl if options.productUrl

	warnUnavailablePost: (formElement) ->
		$.post '/no-cache/AviseMe.aspx', $(formElement).serialize()

# SHARED STUFF
$.skuSelector =
	getAddUrlForSku: (sku, seller = 1, quantity = 1, salesChannel = 1, redirect = true) ->
		"/checkout/cart/add?qty=#{quantity}&seller=#{seller}&sku=#{sku}&sc=#{salesChannel}&redirect=#{redirect}"

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

# EVENTS (DEPRECATED!)
$(document).on "vtex.sku.selected", (evt, sku, productData) ->
	window.FireSkuChangeImage?(sku.sku)
	#window.FireSkuDataReceived?(sku.sku)
	window.FireSkuSelectionChanged?(sku.sku)
