# Alias jQuery internally
$ = window.jQuery

#
# Sku Selector elements function.
#

$.skuSelector = {}

# Renders the Sku Selector inside the given placeholder
# Usage:
# $("#placeholder").skuSelector({skuVariations: json});
# or:
# $("#placeholder").skuSelector({skuVariationsPromise: promise});
$.fn.skuSelector = (options = {}) ->
	opts = $.extend($.fn.skuSelector.defaults, options)
	$el = $(this)
	$el.addClass('sku-selector-loading')
	# console.log('fn.skuSelector', $el, opts)

	unless opts.mainTemplate and opts.dimensionListTemplate and opts.skuDimensionTemplate
		throw new Error('Required option not given.')

	if opts.skuVariations
		skuVariationsDoneHandler opts, opts.skuVariations
	else if opts.skuVariationsPromise
		opts.skuVariationsPromise.done (json) -> opts.skuVariationsDoneHandler($el, opts, json)
		opts.skuVariationsPromise.fail (reason) -> opts.skuVariationsFailHandler($el, opts, reason)
	else
		throw new Error 'You must either provide a JSON or a Promise'

	return $el

$.fn.skuSelector2 = (productId, name, dimensions, skus, options = {}) ->
	options = $.extend($.fn.skuSelector.defaults, options)
	this.addClass('sku-selector-loading')

	selectedDimensionsMap = createDimensionsMap(dimensions)
	uniqueDimensionsMap = calculateUniqueDimensions(dimensions, skus)

	# Finds elements and puts SKU information in them


	renderSkuSelector(this, skus[0].image, name, productId, uniqueDimensionsMap)

	# Initialize content disabling invalid inputs
	disableInvalidInputs(uniqueDimensionsMap,	findUndefinedDimensions(selectedDimensionsMap), selectableSkus(skus, selectedDimensionsMap), this, options.selectors)

	# Checks if there are no available options
	available = (sku for sku in skus when sku.available is true)
	if available.length is 0
		options.selectors.warnUnavailable($template).find('input#notifymeSkuId').val(skus[0].sku)
		options.selectors.warnUnavailable($template).show()
		$('.skuselector-buy-btn', $template).hide()
	else if available.length is 1
		selectedSkuObj = available[0]
		updatePrice(selectedSkuObj, options, $template)

	# Handler for the buy button
	buyButtonHandler = (event) =>
		sku = selectedSku(skus, selectedDimensionsMap)
		if sku
			return options.addSkuToCart(sku.sku, $el)
		else
			errorMessage = 'Por favor, escolha: ' + findUndefinedDimensions(selectedDimensionsMap)[0]
			options.selectors.warning($template).show().text(errorMessage)
		return false

	# Handles changes in the dimension inputs
	dimensionChangeHandler = ->
		dimensionName = $(this).attr('data-dimension')
		dimensionValue = $(this).attr('data-value')
		# console.log 'Change dimension!', dimensionName, dimensionValue
		selectedDimensionsMap[dimensionName] = dimensionValue
		resetNextDimensions(dimensionName, selectedDimensionsMap)
		selectedSkuObj = selectedSku(skus, selectedDimensionsMap)
		undefinedDimensions = findUndefinedDimensions(selectedDimensionsMap)

		options.selectors.warning(this).hide()
		options.selectors.warnUnavailable(this).filter(':visible').hide()

		# Trigger event for interested scripts
		if selectedSkuObj and undefinedDimensions.length is 0
			$el.trigger 'skuSelected', [selectedSkuObj, dimensionName]
			if options.warnUnavailable and not selectedSkuObj.available
				options.selectors.warnUnavailable(this).find('#notifymeSkuId').val(selectedSkuObj.sku)
				options.selectors.warnUnavailable(this).show()

		# Limpa classe de selecionado para todos dessa dimensao
		options.selectors.itemDimensionInput(dimensionName, this).removeClass('checked sku-picked')
		options.selectors.itemDimensionLabel(dimensionName, this).removeClass('checked sku-picked')

		# Coloca classes corretas em si
		options.selectors.itemDimensionValueInput(dimensionName, dimensionValue, this).addClass('checked sku-picked')
		options.selectors.itemDimensionValueLabel(dimensionName, dimensionValue, this).addClass('checked sku-picked')

		disableInvalidInputs(uniqueDimensionsMap, undefinedDimensions,
			selectableSkus(skus, selectedDimensionsMap),
			this, options.selectors)

		# Select first available dimensions
		if selectedSkuObj
			for dimension in undefinedDimensions
				selectDimension(options.selectors.itemDimensionInput(dimension, this))

			updatePrice(selectedSkuObj, options, this)

	# Binds handlers
	options.selectors.buyButton(this).click(buyButtonHandler)
	for dimension in dimensions
		options.selectors.itemDimensionInput(dimension, this).change(dimensionChangeHandler)

	if options.warnUnavailable
		options.selectors.warnUnavailable(this).find('form').submit (e) ->
			e.preventDefault()
			options.selectors.warnUnavailable(this).find('#notifymeLoading').show()
			options.selectors.warnUnavailable(this).find('form').hide()
			xhr = options.warnUnavailablePost(e.target)
			xhr.done -> options.selectors.warnUnavailable(this).find('#notifymeSuccess').show()
			xhr.fail -> options.selectors.warnUnavailable(this).find('#notifymeError').show()
			xhr.always -> options.selectors.warnUnavailable(this).find('#notifymeLoading').hide()
		return false

	# Select first dimension
	if options.selectOnOpening or selectedSku(skus, selectedDimensionsMap)
		selectDimension(options.selectors.itemDimensionInput(dimensions[0], this))

	return this

$.fn.skuSelector.defaults =
	skuVariationsPromise: undefined
	skuVariations: undefined
	addSkuToCartPreventDefault: true
	buyButtonSelector: ''
	warnUnavailable: false
	selectOnOpening: false
	selectors:
		listPriceValue: (context) -> $('.skuselector-list-price .value', context).add('.skuListPrice')
		bestPriceValue: (context) -> $('.skuselector-best-price .value', context).add('.skuBestPrice')
		installment: (context) -> $('.skuselector-installment', context)
		buyButton: (context) -> $('.skuselector-buy-btn', context)
		price: (context) -> $('.skuselector-price', context)
		warning: (context) -> $('.skuselector-warning', context)
		warnUnavailable: (context) -> $('.skuselector-warn-unavailable', context)
		itemDimensionListItem: (dimensionName, context) -> $('.item-dimension-' + sanitize(dimensionName), context)
		itemDimensionInput: (dimensionName, context) -> $('.item-dimension-' + sanitize(dimensionName) + ' input', context)
		itemDimensionLabel: (dimensionName, context) -> $('.item-dimension-' + sanitize(dimensionName) + ' label', context)
		itemDimensionValueInput: (dimensionName, valueName, context) -> $('.item-dimension-' + sanitize(dimensionName) + ' input[value="' + sanitize(valueName) + '"]', context)
		itemDimensionValueLabel: (dimensionName, valueName, context) -> $('.item-dimension-' + sanitize(dimensionName) + ' label.skuespec_' + sanitize(valueName), context)

	updateBuyButtonURL: (url, template)->
		$('.skuselector-buy-btn', template).attr('href', url)

	# Called when we failed to receive variations.
	skuVariationsFailHandler: ($el, options, reason) ->
		$el.removeClass('sku-selector-loading')
		window.location.href = options.productUrl if options.productUrl

	warnUnavailablePost: (formElement) ->
		$.post '/no-cache/AviseMe.aspx', $(formElement).serialize()

#
# SkuSelector Shared Functions
#

# Given a product id, return a promise for a request for the sku variations
$.skuSelector.getSkusForProduct = (productId) ->
	# console.log 'getSkusForProduct', productId
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

updatePrice = (sku, options, template) ->
	if sku and sku.available
		listPrice = formatCurrency sku.listPrice
		price = formatCurrency sku.bestPrice
		installments = sku.installments
		installmentValue = formatCurrency sku.installmentsValue

		# Modifica href do botão comprar
		options.updateBuyButtonURL($.skuSelector.getAddUrlForSku(sku.sku), template)
		options.selectors.price(template).show()
		options.selectors.buyButton(template).show()
		options.selectors.listPriceValue(template).text('R$ ' + listPrice)
		options.selectors.bestPriceValue(template).text('R$ ' + price)
		options.selectors.installment(template).text('ou até ' + installments + 'x de R$ ' + installmentValue) if installments > 1
	else
		# Modifica href do botão comprar
		options.updateBuyButtonURL('javascript:void(0);', template)
		options.selectors.price(template).hide()
		options.selectors.buyButton(template).hide()
		# $('.notifyme-skuid').val()


# Sanitizes text - "Caçoá (teste 2)" becomes "cacoateste2"
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

# Format currency to brazilian reais
formatCurrency = (value) ->
	if value? and not isNaN value
		return parseFloat(value/100).toFixed(2).replace('.',',').replace(/(\d)(?=(\d\d\d)+(?!\d))/g, '$1.')
	else
		return "Grátis"

createDimensionsMap = (dimensions) ->
	selectedDimensionsMap = {}
	for dimension in dimensions
		selectedDimensionsMap[dimension] = undefined
	return selectedDimensionsMap

findUndefinedDimensions = (selectedDimensionsMap) ->
	(key for key, value of selectedDimensionsMap when value is undefined) ? []

resetNextDimensions = (dimensionName, selectedDimensionsMap) ->
	foundCurrent = false
	for key of selectedDimensionsMap
		selectedDimensionsMap[key] = undefined if foundCurrent
		foundCurrent = true if key is dimensionName

calculateUniqueDimensions = (dimensions, skus) ->
	uniqueDimensionsMap = {}
	# For each dimension, lets grab the uniques
	for dimension in dimensions
		uniqueDimensionsMap[dimension] = []
		for sku in skus
			# If this dimension doesnt exist, add it
			skuDimension = sku.dimensions[dimension]
			if $.inArray(skuDimension, uniqueDimensionsMap[dimension]) is -1
				uniqueDimensionsMap[dimension].push skuDimension
	return uniqueDimensionsMap

selectableSkus = (skus, selectedDimensionsMap) ->
	selectableArray = skus[..]
	for sku, i in selectableArray by -1
		match = true
		for dimension, dimensionValue of selectedDimensionsMap when dimensionValue isnt undefined
			skuDimensionValue = sku.dimensions[dimension]
			if skuDimensionValue isnt dimensionValue
				match = false
				continue
		selectableArray.splice(i, 1) unless match
		# selectableArray.splice(i, 1) unless match and sku.available
	return selectableArray

selectedSku = (skus, selectedDimensionsMap) ->
	s = selectableSkus(skus, selectedDimensionsMap)
	return if s.length is 1 then s[0] else undefined

# Renders the DOM elements of the Sku Selector, given the JSON and the templates
renderSkuSelector = (element, image, name, productId, uniqueDimensionsMap) =>
	dimensionIndex = 0

	element.find('.vtexsc-skuProductImage img').attr('src', image).attr('alt', name)
	element.find('.vtexsm-prodTitle').text(name)

	skuListBase = element.find('.skuListEach').remove()
	dimensionListsBase = element.find('.dimensionListsEach').remove()
	for dimension, dimensionValues of uniqueDimensionsMap
		dl = dimensionListsBase.clone()
		dimensionSanitized = sanitize(dimension)

		dl.find('.specification').text(dimension)
		dl.find('.topic').addClass("dimensionSanitized").addClass("item-dimension-#{dimensionSanitized}")
		dl.find('.skuList').addClass('.group_' + dimensionIndex); dimensionIndex++
		for value, i in dimensionValues
			skuList = skuListBase.clone()
			valueSanitized = sanitize(value)

			skuList.find('input').attr('data-dimension', dimension)
				.attr('dimension', dimensionSanitized)
				.attr('name', 'dimension-' + dimensionSanitized)
				.attr('data-value', value)
				.attr('value', valueSanitized)
				.attr('specification', valueSanitized)
				.attr('id', "#{productId}_#{dimensionSanitized}_#{i}")
				.addClass("input-dimension-#{dimensionSanitized} sku-selector skuespec_#{valueSanitized} ")
			skuList.find('label').attr('for', "#{productId}_#{dimensionSanitized}_#{i}")
				.text(value)
				.addClass("dimension-#{dimensionSanitized} espec_#{dimensionIndex} skuespec_#{valueSanitized}")

			skuList.appendTo(dl.find('.skuList'))

		dl.appendTo(element.find('.dimensionLists'))
		
# Disable unselectable SKUs given the current selections
disableInvalidInputs = (uniqueDimensionsMap, undefinedDimensions, selectableSkus, $template, selectors) ->
	# First, find the first undefined dimension selection list
	firstUndefinedDimensionName = undefinedDimensions[0]

	# If there is no undefined dimension, there is nothing to disable.
	return unless firstUndefinedDimensionName

	for dimension in undefinedDimensions
		# Second, disable all options in this row, add disabled class, remove checked class and matching removeAttr checked
		selectors.itemDimensionInput(dimension, $template).addClass('item_unavaliable').removeAttr('checked').removeClass('checked sku-picked').attr('disabled', 'disabled')
		selectors.itemDimensionLabel(dimension, $template).addClass('disabled item_unavaliable').removeClass('checked sku-picked')

		# Third, enable all selectable options in this row
		for value in uniqueDimensionsMap[dimension]
			# Search for the sku dimension value corresponding to this dimension
			for sku in selectableSkus
				skuDimensionValue = sku.dimensions[dimension]
				# If the dimension value matches, enable the button
				if skuDimensionValue is value
					selectors.itemDimensionValueInput(dimension, value, $template).removeAttr('disabled')
				# If the dimension value matches and this sku is available, show as selectable
				if skuDimensionValue is value and sku.available
					selectors.itemDimensionValueInput(dimension, value, $template).removeClass('item_unavaliable')
					selectors.itemDimensionValueLabel(dimension, value, $template).removeClass('disabled item_unavaliable')