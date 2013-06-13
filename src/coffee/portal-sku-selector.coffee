# Alias jQuery internally
$ = window.jQuery

#
# Sku Selector elements function.
#

$.skuSelector = { $placeholder: undefined }

# Renders the Sku Selector inside the given placeholder
# Usage:
# $("#placeholder").skuSelector({skuVariations: json});
# or:
# $("#placeholder").skuSelector({skuVariationsPromise: promise});
$.fn.skuSelector = (options = {}) ->
	opts = $.extend($.fn.skuSelector.defaults, options)
	$el = $(this)
	$el.addClass('sku-selector-loading')
	console.log('fn.skuSelector', $el, opts)

	unless opts.mainTemplate and opts.dimensionListTemplate and opts.skuDimensionTemplate
		throw new Error('Required option not given.')

	if opts.skuVariations
		skuVariationsDoneHandler opts, opts.skuVariations
	else if opts.skuVariationsPromise
		opts.skuVariationsPromise.done (json) -> opts.skuVariationsDoneHandler($el, opts, json)
		opts.skuVariationsPromise.fail (reason) -> opts.skuVariationsFailHandler($el, opts, reason)
	else
		console.error 'You must either provide a JSON or a Promise'

$.fn.skuSelector.defaults =
	skuVariationsPromise: undefined
	skuVariations: undefined
	selectFirstAvailableOnStart: true
	selectFirstAvailableDimensions: true
	addSkuToCartPreventDefault: true
	buyButtonSelector: ''
	selectors:
		listPriceValue: (template) -> $('.skuselector-list-price .value', template).add('.skuListPrice')
		bestPriceValue: (template) -> $('.skuselector-best-price .value', template).add('.skuBestPrice')
		installment: (template) -> $('.skuselector-installment', template)
		price: (template) -> $('.skuselector-price', template)
		warning: (template) -> $('.skuselector-warning', template)
		itemDimensionListItem: (dimensionName, template) -> $('.item-dimension-' + sanitize(dimensionName), template)
		itemDimensionInputEnabled: (dimensionName, template) ->
			inp = $('.item-dimension-' + sanitize(dimensionName) + ' input:not(.item_unavaliable)', template)
			if inp.length > 0
				return inp
			else
				return $('.item-dimension-' + sanitize(dimensionName) + ' input', template)

	updateBuyButtonURL: (url, template)->
		$('.skuselector-buy-btn', template).attr('href', url)

	# Called when we failed to receive variations.
	skuVariationsFailHandler: ($el, options, reason) ->
		$el.removeClass('sku-selector-loading')
		console.error(reason)
		window.location.href = options.productUrl if options.productUrl

#
# SkuSelector Shared Functions
#

# Given a product id, return a promise for a request for the sku variations
$.skuSelector.getSkusForProduct = (productId) ->
	console.log 'getSkusForProduct', productId
	$.get '/api/catalog_system/pub/products/variations/' + productId

$.skuSelector.getAddUrlForSku = (sku, seller = 1, qty = 1, redirect = true) ->
	protocol = if window.location.host.indexOf('vtexlocal') isnt -1 then 'http' else 'https'
	protocol + '://' + window.location.host + "/checkout/cart/add?qty=#{qty}&seller=#{seller}&sku=#{sku}&redirect=#{redirect}"

# Creates the DOM of the Sku Selector, with the appropriate event bindings
$.skuSelector.createSkuSelector = (name, dimensions, skus, options, $el) =>
	# Create selected dimensions map and functions
	selectedDimensionsMap = createDimensionsMap(dimensions)
			
	# Create unique dimensions map
	uniqueDimensionsMap = calculateUniqueDimensions(dimensions, skus)
	console.log 'skuSelector uniqueDimensionsMap', uniqueDimensionsMap

	# Render template string with replacements
	renderedTemplate = renderSkuSelector(skus[0].image, name, 
		uniqueDimensionsMap, 
		options.mainTemplate,
		options.dimensionListTemplate,
		options.skuDimensionTemplate)

	# Create jQuery DOM
	$template = $(renderedTemplate)

	# Initialize content disabling invalid inputs
	disableInvalidInputs(uniqueDimensionsMap, 
		findUndefinedDimensions(selectedDimensionsMap),
		selectableSkus(skus, selectedDimensionsMap),
		$template)

	# Checks if there are no available options
	available = (sku for sku in skus when sku.available is true)
	if available.length is 0
		$('.skuselector-product-unavailable', $template).show()
		$('.skuselector-buy-btn', $template).hide()
	# TODO refactor
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

		# Limpa classe de selecionado para todos dessa dimensao
		options.selectors.itemDimensionListItem(dimensionName, $template).removeClass('checked sku-picked')
		# Adiciona classe de selecionado para seu label
		$(this).parent().addClass('checked sku-picked')
	
		console.log 'Change dimension!', dimensionName, dimensionValue
		selectedDimensionsMap[dimensionName] = dimensionValue
		resetNextDimensions(dimensionName, selectedDimensionsMap)
		disableInvalidInputs(uniqueDimensionsMap,
			findUndefinedDimensions(selectedDimensionsMap),
			selectableSkus(skus, selectedDimensionsMap),
			$template)
		selectedSkuObj = selectedSku(skus, selectedDimensionsMap)
		undefinedDimensions = findUndefinedDimensions(selectedDimensionsMap)

		# Trigger event for interested scripts
		$el.trigger 'skuSelected', [selectedSkuObj, dimensionName] if selectedSkuObj

		if options.selectFirstAvailableDimensions
			for dimension in undefinedDimensions
				dim = options.selectors.itemDimensionInputEnabled(dimension, $template)

				if dim.length > 0
					$(dim[0]).attr('checked', 'checked').change()

			updatePrice(selectedSkuObj, options, $template)

		# Só existe uma possibilidade na próxima dimensão - vamos escolhê-la.
		else if selectedSkuObj and undefinedDimensions.length <= 1
			if undefinedDimensions.length is 1
				$('input:enabled[dimension="' + sanitize(undefinedDimensions[0]) + '"]',
					$template).attr('checked', 'checked').change()

			updatePrice(selectedSkuObj, options, $template)
		else
			options.selectors.price.fadeOut()

	# Binds handlers
	console.log 'bind: ' + '.input-' + sanitize(dimension) for dimension in dimensions
	$('.input-dimension-' + sanitize(dimension), $template).change(dimensionChangeHandler) for dimension in dimensions
	$('.skuselector-buy-btn', $template).click(buyButtonHandler)

	# Select first available item
	if options.selectFirstAvailableOnStart
		for dimension in dimensions
			dim = options.selectors.itemDimensionInputEnabled(dimension, $template)
			if dim.length > 0
				$(dim[0]).attr('checked', 'checked').change()
	return $template

#
# PRIVATE FUNCTIONS
#

updatePrice = (sku, options, template) ->
	if sku and sku.available
		listPrice = formatCurrency sku.listPrice
		price = formatCurrency sku.bestPrice
		installments = sku.installments
		installmentValue = formatCurrency sku.installmentsValue

		# Modifica href do botão comprar
		options.updateBuyButtonURL($.skuSelector.getAddUrlForSku(sku.sku), template)
		options.selectors.price(template).show()
		options.selectors.listPriceValue(template).text('R$ ' + listPrice)
		options.selectors.bestPriceValue(template).text('R$ ' + price)
		options.selectors.installment(template).text('ou até ' + installments + 'x de R$ ' + installmentValue) if installments > 1
	else
		# Modifica href do botão comprar
		options.updateBuyButtonURL('javascript:void(0);', template)
		options.selectors.price(template).hide()
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
		.replace(/\//g, '-')
		.replace(/\(|\)|\'|\"/g, '')
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
			skuDimension = (dim for dim in sku.dimensions when dim.Key is dimension)[0].Value
			if uniqueDimensionsMap[dimension].indexOf(skuDimension) is -1
				uniqueDimensionsMap[dimension].push skuDimension
	return uniqueDimensionsMap

selectableSkus = (skus, selectedDimensionsMap) ->
	selectableArray = skus[..]
	for sku, i in selectableArray by -1
		match = true
		for dimension, dimensionValue of selectedDimensionsMap when dimensionValue isnt undefined
			skuDimensionValue = (dim for dim in sku.dimensions when dim.Key is dimension)[0].Value
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
renderSkuSelector = (image, name, uniqueDimensionsMap, mainTemplate, dimensionListTemplate, skuDimensionTemplate) =>
	dl = ''
	dimensionIndex = 0
	for dimension, dimensionValues of uniqueDimensionsMap
		skuList = ''
		for value, i in dimensionValues
			skuList += skuDimensionTemplate.replace(/\{\{dimension\}\}/g, dimension)
				.replace(/\{\{dimensionSanitized\}\}/g, sanitize(dimension))
				.replace(/\{\{index\}\}/g, i)
				.replace(/\{\{value\}\}/g, value)
				.replace(/\{\{valueSanitized\}\}/g, sanitize(value))
		dl += dimensionListTemplate.replace(/\{\{dimension\}\}/g, dimension)
			.replace(/\{\{dimensionSanitized\}\}/g, sanitize(dimension))
			.replace(/\{\{skuList\}\}/g, skuList)
			.replace(/\{\{dimensionIndex\}\}/g, dimensionIndex++)

	renderedTemplate = mainTemplate.replace('{{image}}', image)
		.replace('{{productAlt}}', name)
		.replace('{{productName}}', name)
		.replace('{{dimensionLists}}', dl)

	return renderedTemplate
		
# Disable unselectable SKUs given the current selections
disableInvalidInputs = (uniqueDimensionsMap, undefinedDimensions, selectableSkus, $template) ->
	# First, find the first undefined dimension selection list
	firstUndefinedDimensionName = undefinedDimensions[0]

	# If there is no undefined dimension, there is nothing to disable.
	return unless firstUndefinedDimensionName

	# Second, disable all options in this row

	# Add disabled class and matching attr disabled
	# $('input[dimension="' + sanitize(firstUndefinedDimensionName) + '"]', $template).attr('disabled', 'disabled')
	$('input[dimension="' + sanitize(firstUndefinedDimensionName) + '"]', $template).addClass('item_unavaliable')
	$('label.dimension-' + sanitize(firstUndefinedDimensionName), $template).addClass('disabled item_unavaliable')
	# Remove checked class and matching removeAttr checked
	$('input[dimension="' + sanitize(firstUndefinedDimensionName) + '"]', $template).removeAttr('checked')
	$('label.dimension-' + sanitize(firstUndefinedDimensionName), $template).removeClass('checked sku-picked')

	# Third, enable all selectable options in this row
	for value in uniqueDimensionsMap[firstUndefinedDimensionName]
		# Search for the sku dimension value corresponding to this dimension
		for sku in selectableSkus
			skuDimensionValue = (dim for dim in sku.dimensions when dim.Key is firstUndefinedDimensionName)[0].Value
			# If the dimension value matches and this sku is available, enable the button
			if skuDimensionValue is value and sku.available
				$value = $('input[dimension="' + sanitize(firstUndefinedDimensionName) + '"][value="' + sanitize(value) + '"]',
					$template)
				# $value.removeAttr('disabled')
				$value.removeClass('item_unavaliable')
				# Remove disabled class, matching removeAttr disabled
				$('label[for="' + $value.attr('id') + '"]', $template).removeClass('disabled item_unavaliable')

	# Fourth, disable next dimensions
	for dimension in undefinedDimensions[1..]
		$('input[dimension="' + sanitize(dimension) + '"]', $template).each ->
			# $(this).attr('disabled', 'disabled')
			$(this).addClass('item_unavaliable')
			$('label.dimension-' + sanitize(dimension), $template).addClass('disabled item_unavaliable')
			$(this).removeAttr('checked')
			$('label.dimension-' + sanitize(dimension), $template).removeClass('checked sku-picked')