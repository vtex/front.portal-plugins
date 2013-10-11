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
class SkuSelector extends ProductComponent
	constructor: (@element, @productData, @options) ->
		@productId = @productData.productId
		@name = @productData.name
		@salesChannel = @productData.salesChannel
		@skus = @productData.skus
		@image = @skus[0].image

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

		@generateSelectors
			listPriceValue: '.skuselector-list-price .value'
			bestPriceValue: '.skuselector-best-price .value'
			installment: '.skuselector-installment'
			buyButton: '.skuselector-buy-btn'
			confirmButton: '.skuselector-confirm-btn'
			price: '.skuselector-price'
			priceRange: '.skuselector-price-range'
			warning: '.skuselector-warning'
			warnUnavailable: '.skuselector-warn-unavailable'
		@findinputs = => $('input, select', @element)
		@finditemDimension = (dimensionName) => $(".item-dimension-#{_.sanitize(dimensionName)}", @element)
		@finditemDimensionInput = (dimensionName) =>	@finditemDimension(dimensionName).find('input')
		@finditemDimensionLabel = (dimensionName) =>	@finditemDimension(dimensionName).find('label')
		@finditemDimensionOption = (dimensionName) => @finditemDimension(dimensionName).find('option')
		@finditemDimensionValueInput = (dimensionName, valueName) =>	@finditemDimension(dimensionName).find("input[value='#{valueName}']")
		@finditemDimensionValueLabel = (dimensionName, valueName) =>	@finditemDimension(dimensionName).find("label.skuespec_#{_.sanitize(valueName)}")
		@finditemDimensionValueOption = (dimensionName, valueName) => @finditemDimension(dimensionName).find("option[value='#{valueName}']")

		@init()

	init: =>
		@update()

		if @options.selectOnOpening
			for sku in @skus
				if sku.available
					@selectSku(sku)
					break

		@render()
		@bindEvents()
		if @skus.length == 1
			@triggerProductEvent 'vtex.sku.selected', @skus[0]

	update: (dimensionName, dimensionValue) =>
		index = -1
		for dimension, i in @dimensions
			if dimension.name is dimensionName
				dimension.selected = dimensionValue
				index = i

		for dimension, i in @dimensions by -1
			break if index is i
			status = @findSelectionStatus((dim.selected for dim in @dimensions))
			dimension.selected = null if status is 'invalid'

		for dimension, i in @dimensions by -1
			if dimension.selected isnt null or dimension.selected isnt undefined
				lastSelected = i

		originalSelection = (dim.selected for dim in @dimensions)

		for dimension, i in @dimensions
			@resetDimension(dimension)

			if i > lastSelected
				for value in dimension.values
					selection = originalSelection.slice(0)
					selection[i] = value
					switch @findSelectionStatus(selection)
						when "invalid"
							@disableInvalidValue(dimension, value)
						when "unavailable"
							@disableUnavailableValue(dimension, value)

			@selectValue(dimension)

		selectableSkus = @findSelectableSkus()

		@triggerProductEvent 'vtex.sku.dimensionChanged', dimensionName, dimensionValue
		if selectableSkus.length == 1
			@triggerProductEvent 'vtex.sku.selected', selectableSkus[0]
			@triggerProductEvent 'skuSelected', selectableSkus[0]
		else
			@triggerProductEvent 'vtex.sku.unselected', selectableSkus
			if selectableSkus.length > 1
				@triggerProductEvent 'vtex.sku.selectable', selectableSkus

		# ToDo remover quando alterar viewpart de modal
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
				@showWarnUnavailable(selectedSku.sku) if @options.warnUnavailable
				@hideBuyButton()
		else if selectableSkus.length > 1 and @options.showPriceRange
			@showPriceRange(@findPrices(selectableSkus))

	isSelectedInexistent: =>
		@findSelectableSkus().length == 0

	render: =>
		templateName = if @options.modalLayout then 'sku-selector-modal' else 'sku-selector-product'
		dust.render templateName, @, (err, out) =>
			throw new Error "Sku Selector Dust error: #{err}" if err
			@element.html out
			@update()
			@showBuyButton()
			@buyIfNoVariations()
			@element.trigger('vtex.sku.ready')

	bindEvents: =>
		@findinputs().on 'change', @dimensionChangeHandler

		# ToDo remover quando alterar viewpart de modal
		@findbuyButton().on 'click', @buyButtonHandler
		@findwarnUnavailable().find('form').on 'submit', @warnUnavailableSubmitHandler if @options.warnUnavailable


	dimensionChangeHandler: (evt) =>
		$this = $(evt.target)

		dimensionName = $this.data('dimension')
		dimensionValue = if $this.val() is "" then undefined else $this.val()

		@update(dimensionName, dimensionValue)

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
			if selection[i] isnt undefined and selection[i] isnt null and selection[i] isnt value
				return false
		return true

	resetDimension: (dimension) =>
		@finditemDimensionInput(dimension.name)
		.removeAttr('checked')
		.removeAttr('disabled')
		.removeClass('item_unavaliable sku-picked checked item_unavailable item_doesnt_exist combination_unavaliable')

		@finditemDimensionLabel(dimension.name)
		.removeClass('item_unavaliable sku-picked checked item_unavailable disabled item_doesnt_exist combination_unavaliable')

		@finditemDimensionOption(dimension.name)
		.removeClass('item_unavaliable sku-picked checked item_unavailable disabled item_doesnt_exist combination_unavaliable')
		.removeAttr('disabled')
		.removeAttr('selected')

	selectValue: (dimension) =>
		value = dimension.selected

		if value is null or value is undefined
			@finditemDimensionInput(dimension.name)
			.removeAttr('checked')
			@finditemDimensionOption(dimension.name)
			.removeAttr('selected')
			@finditemDimensionValueOption(dimension.name, "")
			.attr('selected', 'selected')
		else
			@finditemDimensionValueInput(dimension.name, value)
			.attr('checked', 'checked')
			.addClass('checked sku-picked')
			@finditemDimensionValueLabel(dimension.name, value)
			.addClass('checked sku-picked')
			@finditemDimensionValueOption(dimension.name, value)
			.attr('selected', 'selected')
			.addClass('checked sku-picked')

	disableInvalidValue: (dimension, value) =>
		@finditemDimensionValueInput(dimension.name, value)
		.addClass('item_doesnt_exist combination_unavaliable').attr('disabled', 'disabled')
		@finditemDimensionValueLabel(dimension.name, value)
		.addClass('item_doesnt_exist combination_unavaliable')
		@finditemDimensionValueOption(dimension.name, value)
		.addClass('item_doesnt_exist combination_unavaliable').attr('disabled', 'disabled')

	disableUnavailableValue: (dimension, value) =>
		@finditemDimensionValueInput(dimension.name, value)
		.addClass('item_unavaliable item_unavailable')
		@finditemDimensionValueLabel(dimension.name, value)
		.addClass('item_unavaliable item_unavailable disabled')
		@finditemDimensionValueOption(dimension.name, value)
		.addClass('item_unavaliable item_unavailable disabled')

	# ToDo remover quando alterar viewpart de modal
	buyButtonHandler: (event) =>
		selectedSku = @findSelectedSku()
		if selectedSku
			if @options.confirmBuy
				event.preventDefault()
				@showConfirmButton(selectedSku)
			else
				$(window).trigger 'vtex.modal.hide'
				$.get($.skuSelector.getAddUrlForSku(selectedSku.sku, 1, 1, @productData.salesChannel, false))
				.done (data) =>
						$(window).trigger 'productAddedToCart'
				.fail (jqXHR, status) =>
						window.location.href = $.skuSelector.getAddUrlForSku(selectedSku.sku, 1, @productData.salesChannel)
				return false
		else
			@findwarning().show().text('Por favor, escolha: ' + @findUndefinedDimensions()[0].name)
			return false

	warnUnavailableSubmitHandler: (evt) =>
		evt.preventDefault()
		@findwarnUnavailable().find('.sku-notifyme-loading').show()
		@findwarnUnavailable().find('form').hide()
		xhr =	$.post '/no-cache/AviseMe.aspx', $(evt.target).serialize()
		xhr.done -> @findwarnUnavailable().find('.sku-notifyme-success').show()
		xhr.fail -> @findwarnUnavailable().find('.sku-notifyme-loading-error').show()
		xhr.always -> @findwarnUnavailable().find('.sku-notifyme-loading').hide()
		return false

	findPrices: (skus = undefined) =>
		skus or= @findSelectableSkus()
		skus = (sku for sku in skus when sku.available)
		$.map(skus, (sku) -> sku.bestPrice).sort( (a,b) -> return parseInt(a) - parseInt(b) )

	buyIfNoVariations: =>
		if @skus.length < 2 and @options.modalLayout
			setTimeout (=> @findbuyButton().click()), 1

	hideBuyButton: =>
		@findbuyButton().attr('href', 'javascript:void(0);').hide()

	hideConfirmButton: =>
		@findconfirmButton().attr('href', 'javascript:void(0);').hide()

	hidePrice: =>
		@findprice().hide()

	hidePriceRange: =>
		@findpriceRange().hide()

	hideWarnUnavailable: =>
		@findwarning().hide()
		@findwarnUnavailable().filter(':visible').hide()

	showBuyButton: (sku) =>
		@findbuyButton().show().parent().show()
		@findbuyButton().attr('href', $.skuSelector.getAddUrlForSku(sku.sku, sku.sellerId, 1, @salesChannel, @options.redirect)) if sku

	showConfirmButton: (sku) =>
		dimensionsText = $.map(sku.dimensions, (k, v) -> k).join(', ')

		@findconfirmButton()
		.attr('href', $.skuSelector.getAddUrlForSku(sku.sku, sku.sellerId, 1, @salesChannel, @options.redirect))
		.show()
		.find('.skuselector-confirm-dimensions').text(dimensionsText)

	showPrice: (sku) =>
		listPrice = _.formatCurrency sku.listPrice/100
		bestPrice = _.formatCurrency sku.bestPrice/100
		installments = sku.installments
		installmentValue = _.formatCurrency sku.installmentsValue/100

		@findlistPriceValue().text("R$ #{listPrice}")
		@findbestPriceValue().text("R$ #{bestPrice}")
		if installments > 1
			@findinstallment().text("ou até #{installments}x de R$ #{installmentValue}")

		@findprice().show()

	showPriceRange: (prices) =>
		$priceRange = @findpriceRange().show()
		min = _.formatCurrency prices[0]/100
		max = _.formatCurrency prices[prices.length-1]/100
		$priceRange.find('.lowPrice').text(" R$ #{min} ")
		$priceRange.find('.highPrice').text(" R$ #{max} ")

	showWarnUnavailable: (sku) =>
		@findwarnUnavailable().show().find('input.sku-notifyme-skuid').val(sku)


# PLUGIN ENTRY POINT
$.fn.skuSelector = (productData, jsOptions = {}) ->
	defaultOptions = $.extend true, {}, $.fn.skuSelector.defaults
	for element in this
		$element = $(element)
		$element.addClass('sku-selector-loading')
		domOptions = $element.data()
		options = $.extend(true, defaultOptions, domOptions, jsOptions)
		unless $element.data('skuSelector')
			$element.data('skuSelector', new SkuSelector($element, productData, options))

		$element.removeClass('sku-selector-loading')

	return this


# PLUGIN DEFAULTS
$.fn.skuSelector.defaults =
	modalLayout: false
	warnUnavailable: false
	selectOnOpening: false
	confirmBuy: false
	showPriceRange: false

# SHARED STUFF
$.skuSelector =
	getAddUrlForSku: (sku, seller = 1, quantity = 1, salesChannel = 1, redirect = true) ->
		"/checkout/cart/add?qty=#{quantity}&seller=#{seller}&sku=#{sku}&sc=#{salesChannel}&redirect=#{redirect}"

# EVENTS (DEPRECATED!)
$(document).on "vtex.sku.selected", (evt, productId, sku) ->
	window.FireSkuChangeImage?(sku.sku)
	#window.FireSkuDataReceived?(sku.sku)
	window.FireSkuSelectionChanged?(sku.sku)

$(document).on 'vtex.sku.selectable', (evt, productId, skus) ->
	window.FireSkuChangeImage?(skus[0].sku)
