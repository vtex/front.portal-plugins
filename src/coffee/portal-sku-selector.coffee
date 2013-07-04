# Alias jQuery internally
$ = window.jQuery

# Sku Selector elements function.
$.skuSelector = {}


#
# CLASSE
#

# TODO separar em classes menores
class SkuSelector
	constructor: (productData) ->
		@productId = productData.productId
		@name = productData.name
		@dimensions = productData.dimensions
		@skus = productData.skus

		#Create dimensions map
		@selectedDimensionsMap = {}
		@selectedDimensionsMap[dimension] = undefined for dimension in @dimensions

		# Object of structure { dimension : [possibility] }
		@uniqueDimensionsMap = @findUniqueDimensions()

	findUniqueDimensions: =>
		uniqueDimensionsMap = {}
		# For each dimension, lets grab the uniques
		for dimension in @dimensions
			uniqueDimensionsMap[dimension] = []
			for sku in @skus
				# If this dimension doesnt exist, add it
				skuDimension = sku.dimensions[dimension]
				if $.inArray(skuDimension, uniqueDimensionsMap[dimension]) is -1
					uniqueDimensionsMap[dimension].push skuDimension
		return uniqueDimensionsMap

	findUndefinedDimensions: =>
		(key for key, value of @selectedDimensionsMap when value is undefined)

	findAvailableSkus: =>
		(sku for sku in @skus when sku.available)

	findSelectableSkus: =>
		# copy the skus array and then mutate the copy
		selectableSkus = @skus[..]
		for sku, i in selectableSkus by -1
			match = true
			for dimension, dimensionValue of @selectedDimensionsMap when dimensionValue isnt undefined
				skuDimensionValue = sku.dimensions[dimension]
				if skuDimensionValue isnt dimensionValue
					match = false
					continue
			selectableSkus.splice(i, 1) unless match #and sku.available
		return selectableSkus

  findAvailableSkus: =>
    (sku for sku in @skus when sku.available is true)

	findSelectedSku: =>
		s = @findSelectableSkus()
		return if s.length is 1 then s[0] else undefined

	getSelectedDimension: (dimension) =>
		@selectedDimensionsMap[dimension]

	setSelectedDimension: (dimension, value) =>
		@selectedDimensionsMap[dimension] = value

	resetNextDimensions: (theDimension) =>
		currentIndex = @dimensions.indexOf(theDimension)

		for dimension, i in @dimensions when i > currentIndex
			@setSelectedDimension(dimension, undefined)

	# Renders the DOM elements of the Sku Selector, given the context
	renderSkuSelector: (context) =>
		dimensionIndex = 0

		image = @skus[0].image

		context.find('.vtexsc-skuProductImage img').attr('src', image).attr('alt', @name)
		context.find('.vtexsm-prodTitle').text(@name)

		skuListBase = context.find('.skuListEach').remove()
		dimensionListsBase = context.find('.dimensionListsEach').remove()
		for dimension, dimensionValues of @uniqueDimensionsMap
			dimensionList = dimensionListsBase.clone()
			dimensionSanitized = sanitize(dimension)

			dimensionList.find('.specification').text(dimension)
			dimensionList.find('.topic').addClass("#{dimensionSanitized}").addClass("item-dimension-#{dimensionSanitized}")
			dimensionList.find('.skuList').addClass("group_#{dimensionIndex}")
			dimensionIndex++
			for value, i in dimensionValues
				skuList = skuListBase.clone()
				valueSanitized = sanitize(value)

				skuList.find('input').attr('data-dimension', dimension)
					.attr('dimension', dimensionSanitized)
					.attr('name', "dimension-#{dimensionSanitized}")
					.attr('data-value', value)
					.attr('value', valueSanitized)
					.attr('specification', valueSanitized)
					.attr('id', "#{@productId}_#{dimensionSanitized}_#{i}")
					.addClass("input-dimension-#{dimensionSanitized}")
					.addClass("sku-selector")
					.addClass("skuespec_#{valueSanitized}")
				skuList.find('label').text(value)
					.attr('for', "#{@productId}_#{dimensionSanitized}_#{i}")
					.addClass("dimension-#{dimensionSanitized}")
					.addClass("espec_#{dimensionIndex}")
					.addClass("skuespec_#{valueSanitized}")

				skuList.appendTo(dimensionList.find('.skuList'))

			dimensionList.appendTo(context.find('.dimensionLists'))

	disableInvalidInputs: (context, selectors) =>
		undefinedDimensions = @findUndefinedDimensions()
		selectableSkus = @findSelectableSkus()

		for dimension in undefinedDimensions
			# Disable all options in this row, add disabled class, remove checked class and matching removeAttr checked
			selectors.itemDimensionInput(dimension, context)
				.addClass('item_unavaliable')
				.removeClass('checked sku-picked')
				.attr('disabled', 'disabled')
				.removeAttr('checked')
			selectors.itemDimensionLabel(dimension, context)
				.addClass('disabled item_unavaliable')
				.removeClass('checked sku-picked')

			# Enable all selectable options in this row
			for value in @uniqueDimensionsMap[dimension]
				# Search for the sku dimension value corresponding to this dimension
				for sku in selectableSkus
					skuDimensionValue = sku.dimensions[dimension]
					# If the dimension value matches, enable the button
					if skuDimensionValue is value
						selectors.itemDimensionValueInput(dimension, value, context).removeAttr('disabled')
					# If the dimension value matches and this sku is available, show as selectable
					if skuDimensionValue is value and sku.available
						selectors.itemDimensionValueInput(dimension, value, context).removeClass('item_unavaliable')
						selectors.itemDimensionValueLabel(dimension, value, context).removeClass('disabled item_unavaliable')

#
# PLUGIN ENTRY POINT
#
$.fn.skuSelector = (productData, jsOptions = {}) ->
	context = this
	this.addClass('sku-selector-loading')

	# Gather options
	domOptions = this.data()
	defaultOptions = $.fn.skuSelector.defaults
	# Build final options object (priority: js, then dom, then default)
	# Deep extending with true, for the selectors
	options = $.extend(true, defaultOptions, domOptions, jsOptions)

	# Instantiate our singleton
	skuSelectorObj = new SkuSelector(productData)

	# Finds elements and puts SKU information in them
	skuSelectorObj.renderSkuSelector(this)

	# Initialize content disabling invalid inputs
	skuSelectorObj.disableInvalidInputs(this, options.selectors)

	# Checks if there are no available options
	available = skuSelectorObj.findAvailableSkus()
	if available.length is 0
		# showWarningUnavailable
		options.selectors.warnUnavailable(this).find('input#notifymeSkuId').val(skus[0].sku)
		options.selectors.warnUnavailable(this).show()
		options.selectors.buyButton(this).hide()
	else if available.length is 1
		updatePrice(available[0], options, this)

	# Handler for the buy button
	buyButtonHandler = (event) =>
		selectedSku = skuSelectorObj.findSelectedSku()
		if selectedSku
			return options.addSkuToCart(selectedSku.sku, context)
		else
			options.selectors.warning(context).show().text('Por favor, escolha: ' + skuSelectorObj.findUndefinedDimensions()[0])
			return false

	# Handles changes in the dimension inputs
	dimensionChangeHandler = (event) ->
		dimensionName = $(this).attr('data-dimension')
		dimensionValue = $(this).attr('data-value')
		skuSelectorObj.setSelectedDimension(dimensionName, dimensionValue)
		skuSelectorObj.resetNextDimensions(dimensionName)
		selectedSku = skuSelectorObj.findSelectedSku()
		undefinedDimensions = skuSelectorObj.findUndefinedDimensions()

		options.selectors.warning(context).hide()
		options.selectors.warnUnavailable(context).filter(':visible').hide()

		# Trigger event for interested scripts
		if selectedSku and undefinedDimensions.length is 0
			$(this).trigger('skuSelected', [selectedSku, dimensionName])
			if options.warnUnavailable and not selectedSku.available
				options.selectors.warnUnavailable(context).find('#notifymeSkuId').val(selectedSku.sku)
				options.selectors.warnUnavailable(context).show()

		# Limpa classe de selecionado para todos dessa dimensao
		options.selectors.itemDimensionInput(dimensionName, context).removeClass('checked sku-picked')
		options.selectors.itemDimensionLabel(dimensionName, context).removeClass('checked sku-picked')

		# Coloca classes corretas em si
		options.selectors.itemDimensionValueInput(dimensionName, dimensionValue, context).addClass('checked sku-picked')
		options.selectors.itemDimensionValueLabel(dimensionName, dimensionValue, context).addClass('checked sku-picked')

		skuSelectorObj.disableInvalidInputs(context, options.selectors)

		# Select first available dimensions
		if selectedSku
			for dimension in undefinedDimensions
				selectDimension(options.selectors.itemDimensionInput(dimension, context))

		updatePrice(selectedSku, options, context)

	# Handles submission in the warn unavailable form
	warnUnavailableSubmitHandler = (e) ->
		e.preventDefault()
		options.selectors.warnUnavailable(context).find('#notifymeLoading').show()
		options.selectors.warnUnavailable(context).find('form').hide()
		xhr = options.warnUnavailablePost(e.target)
		xhr.done -> options.selectors.warnUnavailable(context).find('#notifymeSuccess').show()
		xhr.fail -> options.selectors.warnUnavailable(context).find('#notifymeError').show()
		xhr.always -> options.selectors.warnUnavailable(context).find('#notifymeLoading').hide()
		return false


	# Binds handlers
	options.selectors.buyButton(this)
		.click(buyButtonHandler)

	for dimension in skuSelectorObj.dimensions
		options.selectors.itemDimensionInput(dimension, this)
			.change(dimensionChangeHandler)

	if options.warnUnavailable
		options.selectors.warnUnavailable(this).find('form')
			.submit(warnUnavailableSubmitHandler)

	# Select first dimension
	if options.selectOnOpening or skuSelectorObj.findSelectedSku()
		selectDimension(options.selectors.itemDimensionInput(dimensions[0], this))

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
		listPriceValue: (context) -> $('.skuselector-list-price .value', context)
		bestPriceValue: (context) -> $('.skuselector-best-price .value', context)
		installment: (context) -> $('.skuselector-installment', context)
		buyButton: (context) -> $('.skuselector-buy-btn', context)
		price: (context) -> $('.skuselector-price', context)
		warning: (context) -> $('.skuselector-warning', context)
		warnUnavailable: (context) -> $('.skuselector-warn-unavailable', context)
		# TODO remover seletores abaixo
		itemDimensionListItem: (dimensionName, context) -> $(".item-dimension-#{sanitize(dimensionName)}", context)
		itemDimensionInput: (dimensionName, context) -> $(".item-dimension-#{sanitize(dimensionName)} input", context)
		itemDimensionLabel: (dimensionName, context) -> $(".item-dimension-#{sanitize(dimensionName)} label", context)
		itemDimensionValueInput: (dimensionName, valueName, context) -> $(".item-dimension-#{sanitize(dimensionName)} input[value='#{sanitize(valueName)}']", context)
		itemDimensionValueLabel: (dimensionName, valueName, context) -> $(".item-dimension-#{sanitize(dimensionName)} label.skuespec_#{sanitize(valueName)}", context)


	# Called when we failed to receive variations.
	skuVariationsFailHandler: ($el, options, reason) ->
		$el.removeClass('sku-selector-loading')
		window.location.href = options.productUrl if options.productUrl

	warnUnavailablePost: (formElement) ->
		$.post '/no-cache/AviseMe.aspx', $(formElement).serialize()


#
# PLUGIN SHARED FUNCTIONS
#

# Given a product id, return a promise for a request for the sku variations
$.skuSelector.getSkusForProduct = (productId) ->
	$.get '/api/catalog_system/pub/products/variations/' + productId

$.skuSelector.getAddUrlForSku = (sku, seller = 1, qty = 1, redirect = true) ->
	window.location.protocol + '//' + window.location.host + "/checkout/cart/add?qty=#{qty}&seller=#{seller}&sku=#{sku}&redirect=#{redirect}"


#
# PRIVATE FUNCTIONS
#
selectDimension = (dimArray) ->
	# Tenta selecionar apenas dos disponíveis
	available = dimArray.filter('input:not(.item_unavaliable)')
	# Caso não haja indisponível, seleciona primeiro não-desabilitado (sku existente)
	el = (if available.length > 0 then available else dimArray).filter('input:enabled')[0]
	$(el).attr('checked', 'checked').change() if dimArray.length > 0

updatePrice = (sku, options, context) ->
	if sku and sku.available
		updatePriceAvailable(sku, options, context)
	else
		updatePriceUnavailable(options, context)

updatePriceAvailable = (sku, options, context) ->
	listPrice = formatCurrency sku.listPrice
	bestPrice = formatCurrency sku.bestPrice
	installments = sku.installments
	installmentValue = formatCurrency sku.installmentsValue

	# Modifica href do botão comprar
	options.selectors.buyButton(context).attr('href', $.skuSelector.getAddUrlForSku(sku.sku)).show()
	options.selectors.price(context).show()
	options.selectors.listPriceValue(context).text("R$ #{listPrice}")
	options.selectors.bestPriceValue(context).text("R$ #{bestPrice}")
	if installments > 1
		options.selectors.installment(context).text("ou até #{installments}x de R$ #{installmentValue}")

updatePriceUnavailable = (options, context) ->
	# Modifica href do botão comprar
	options.selectors.buyButton(context).attr('href', 'javascript:void(0);').hide()
	options.selectors.price(context).hide()
	# $('.notifyme-skuid').val()


#
# UTILITY FUNCTIONS
#

# Sanitizes text: "Caçoá (teste 2)" becomes "Cacoateste2"
# TODO resolver ambiguidade: "15 kg" e "1,5 kg" ambos viram "15kg"
sanitize = (str = this) ->
	specialChars =  "ąàáäâãåæćęèéëêìíïîłńòóöôõøśùúüûñçżź"
	plain = "aaaaaaaaceeeeeiiiilnoooooosuuuunczz"
	regex = new RegExp '[' + specialChars + ']', 'g'
	str += ""
	sanitized = str.replace(regex, (char) ->
		plain.charAt (specialChars.indexOf char))
		.replace(/\s/g, '')
		.replace(/\/|\\/g, '-')
		.replace(/\(|\)|\'|\"|\.|\,/g, '')
		.toLowerCase()
	return sanitized.charAt(0).toUpperCase() + sanitized.slice(1)

# Format currency to brazilian reais: 123455 becomes "1.234,55"
formatCurrency = (value) ->
	if value? and not isNaN value
		return parseFloat(value/100).toFixed(2).replace('.',',').replace(/(\d)(?=(\d\d\d)+(?!\d))/g, '$1.')
	else
		return "Grátis"


#
# EXPORTS
#
window.vtex or= {}
vtex.portalPlugins or= {}
vtex.portalPlugins.SkuSelector = SkuSelector