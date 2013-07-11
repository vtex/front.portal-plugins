$ = window.jQuery

#
# CLASSES
#

# TODO separar em classes menores
class SkuSelector
	constructor: (productData) ->
		@productId = productData.productId
		@name = productData.name
		@skus = productData.skus
		i = 0
		@dimensions = ({
			index: i++
			name: dimensionName
			nameSanitized: sanitize(dimensionName)
			values: productData.dimensionsMap[dimensionName]
			valuesSanitized: (sanitize(value) for value in productData.dimensionsMap[dimensionName])
			availableValues: (true for value in productData.dimensionsMap[dimensionName])
			validValues: (true for value in productData.dimensionsMap[dimensionName])
			selected: undefined
			inputType: productData.dimensionsInputType?[dimensionName] || "radio"
		} for dimensionName in productData.dimensions)

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

	findSelectedSku: =>
		s = @findSelectableSkus()
		return if s.length is 1 then s[0] else undefined

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
		selectors = options.selectors
		@context = context
		@warnUnavailable = options.warnUnavailable

		#SkuSelector
		@data = data

		# Build selectors from given select strings.
		@select = mapObj selectors, (key, val) =>
			( => $(val, @context) )

		@select.inputs = => $('input, select', @context)
		@select.itemDimension = (dimensionName) => $('.' + @generateItemDimensionClass(dimensionName), @context)
		@select.itemDimensionInput = (dimensionName) =>	@select.itemDimension(dimensionName).find('input')
		@select.itemDimensionLabel = (dimensionName) =>	@select.itemDimension(dimensionName).find('label')
		@select.itemDimensionOption = (dimensionName) => @select.itemDimension(dimensionName).find('option')
		@select.itemDimensionValueInput = (dimensionName, valueName) =>	@select.itemDimension(dimensionName).find("input[value='#{valueName}']")
		@select.itemDimensionValueLabel = (dimensionName, valueName) =>	@select.itemDimension(dimensionName).find("label.skuespec_#{sanitize(valueName)}")
		@select.itemDimensionValueOption = (dimensionName, valueName) => @select.itemDimension(dimensionName).find("option[value='#{valueName}']")


	generateItemDimensionClass: (dimensionName) =>
		"item-dimension-#{sanitize(dimensionName)}"

	# Renders the DOM elements of the Sku Selector
	renderSkuSelector: (selector) =>
		dimensionIndex = 0

		image = @data.skus[0].image

		@context.find('.vtexsc-skuProductImage img').attr('src', image).attr('alt', @data.name)
		@context.find('.vtexsm-prodTitle').text(@data.name)

		# The order matters, because .skuListEach is inside .dimensionListsEach
		skuListRadioBase = @context.find('.skuListBase-radio').remove()
		skuListComboBase = @context.find('.skuListBase-combo').remove()
		dimensionListsBase = @context.find('.dimensionListsEach').remove()
		for dimension in @data.dimensions
			dimensionList = dimensionListsBase.clone()

			dimensionList.find('.specification').text(dimension.name)
			dimensionList.find('.topic').addClass("#{dimension.nameSanitized}").addClass(@generateItemDimensionClass(dimension.name))
			dimensionList.find('.skuList').addClass("group_#{dimension.index}")

			skuList = switch dimension.inputType
				when "radio", "Radio" then @_buildRadio(dimension, skuListRadioBase)
				when "combo", "Combo", "select", "Select" then @_buildCombo(dimension, skuListComboBase)
				else @_buildRadio(dimension, skuListRadioBase)

			skuList.appendTo(dimensionList.find('.skuList'))

			dimensionList.appendTo(@context.find('.dimensionLists'))

	_buildRadio: (dimension, base) =>
		list = $('<span></span>')
		for value, i in dimension.values

			skuList = base.clone()
			valueSanitized = dimension.valuesSanitized[i]

			skuList.find('input').attr('data-dimension', dimension.name)
				.attr('dimension', dimension.nameSanitized)
				.attr('name', "dimension-#{dimension.nameSanitized}")
				.attr('value', value)
				.attr('specification', valueSanitized)
				.attr('id', "#{@data.productId}_#{dimension.nameSanitized}_#{i}")
				.addClass(@generateItemDimensionClass(dimension.name))
				.addClass("sku-selector")
				.addClass("skuespec_#{valueSanitized}")
			skuList.find('label').text(value)
				.attr('for', "#{@data.productId}_#{dimension.nameSanitized}_#{i}")
				.addClass("dimension-#{dimension.nameSanitized}")
				.addClass("espec_#{dimension.index}")
				.addClass("skuespec_#{valueSanitized}")

			skuList.appendTo(list)

		return list

	_buildCombo: (dimension, base) =>
		list = base.clone()

		select = list.find('select')

		select.attr('id', "espec_#{dimension.index}_opcao_0")
			.attr('name', "espec_#{dimension.index}")
			.attr('data-dimension', dimension.name)
			.attr('specification', dimension.nameSanitized)
			.attr('currentproductid', @data.productId)

		optionBase = select.find('option')

		for value, i in dimension.values
			option = optionBase.clone()
			valueSanitized = dimension.valuesSanitized[i]

			option.attr('value', value)
				.addClass("skuopcao_#{i}")
				.text(value)

			option.appendTo(select)

		return list

	smartUpdate: =>
		for dimension in @data.dimensions
			@resetDimension(dimension)
			@selectValue(dimension)

			for value, i in dimension.values
				unless dimension.validValues[i]
					@disableInvalidValue(dimension, value)
				unless dimension.availableValues[i]
					@disableUnavailableValue(dimension, value)

		@hideWarnUnavailable()
		selectedSku = @data.findSelectedSku()
		if @warnUnavailable and selectedSku?.available
			@showWarnUnavailable(selectedSku.sku)

		@updatePrice()


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

	updatePrice: (sku) ->
		if sku and sku.available
			@updatePriceAvailable(sku)
		else
			@updatePriceUnavailable()

	updatePriceAvailable: (sku) ->
		listPrice = $.formatCurrency sku.listPrice
		bestPrice = $.formatCurrency sku.bestPrice
		installments = sku.installments
		installmentValue = $.formatCurrency sku.installmentsValue

		# Modifica href do botão comprar
		@select.buyButton().attr('href', $.skuSelector.getAddUrlForSku(sku.sku, sku.sellerId)).show()
		@select.price().show()
		@select.listPriceValue().text("R$ #{listPrice}")
		@select.bestPriceValue().text("R$ #{bestPrice}")
		if installments > 1
			@select.installment().text("ou até #{installments}x de R$ #{installmentValue}")

	updatePriceUnavailable: () ->
		# Modifica href do botão comprar
		# $('.notifyme-skuid').val()
		@select.buyButton().attr('href', 'javascript:void(0);').hide()
		@select.price().hide()

	hideWarnUnavailable: =>
		@select.warning().hide()
		@select.warnUnavailable().filter(':visible').hide()

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
	window.selector = selector
	renderer = new SkuSelectorRenderer(this, options, selector)

	selector.smartUpdate()

	# Finds elements and puts SKU information in them
	renderer.renderSkuSelector()
	renderer.smartUpdate()

	# Checks if there are no available options
	available = selector.findAvailableSkus()
	if available.length is 0
		renderer.showWarnUnavailable(skus[0].sku)
		renderer.select.buyButton().hide()
	else if available.length is 1
		renderer.updatePrice(available[0])

	# Handler for the buy button
	buyButtonHandler = (event) =>
		selectedSku = selector.findSelectedSku()
		if selectedSku
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
		e.preventDefault()
		renderer.select.warnUnavailable().find('#notifymeLoading').show()
		renderer.select.warnUnavailable().find('form').hide()
		xhr = options.warnUnavailablePost(e.target)
		xhr.done -> renderer.select.warnUnavailable().find('#notifymeSuccess').show()
		xhr.fail -> renderer.select.warnUnavailable().find('#notifymeError').show()
		xhr.always -> renderer.select.warnUnavailable().find('#notifymeLoading').hide()
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


	this.removeClass('sku-selector-loading')

	# Chaining
	return this


#
# PLUGIN DEFAULTS
#
$.fn.skuSelector.defaults =
	addSkuToCartPreventDefault: true
	warnUnavailable: false
	selectOnOpening: false
	selectors:
		listPriceValue: '.skuselector-list-price .value'
		bestPriceValue: '.skuselector-best-price .value'
		installment: '.skuselector-installment'
		buyButton: '.skuselector-buy-btn'
		price: '.skuselector-price'
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
# UTILITY FUNCTIONS
#

# Sanitizes text: "Caçoá (teste 2)" becomes "Cacoateste2"
sanitize = (str = this) ->
	specialChars =  "ąàáäâãåæćęèéëêìíïîłńòóöôõøśùúüûñçżź,."
	plain = "aaaaaaaaceeeeeiiiilnoooooosuuuunczzVP"
	regex = new RegExp '[' + specialChars + ']', 'g'
	str += ""
	sanitized = str
		.replace(/\s/g, '')
		.replace(/\/|\\/g, '-')
		.replace(/\(|\)|\'|\"/g, '')
		.toLowerCase()
		.replace regex, (char) ->
			plain.charAt (specialChars.indexOf char)

	return capitalize(sanitized)

capitalize = (str) ->
	return str.charAt(0).toUpperCase() + str.slice(1)

# Format currency to brazilian reais: 123455 becomes "1.234,55"
$.formatCurrency = (value) ->
	if value? and not isNaN value
		return parseFloat(value/100).toFixed(2).replace('.',',').replace(/(\d)(?=(\d\d\d)+(?!\d))/g, '$1.')
	else
		return "Grátis"

mapObj = (obj, f) ->
	obj2 = {}
	for own k, v of obj
		obj2[k] = f k, v
	obj2


#
# EXPORTS
#
window.vtex or= {}
vtex.portalPlugins or= {}
vtex.portalPlugins.SkuSelector = SkuSelector
vtex.portalPlugins.SkuSelectorRenderer = SkuSelectorRenderer