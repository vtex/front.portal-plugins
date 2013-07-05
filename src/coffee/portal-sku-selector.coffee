$ = window.jQuery

#
# CLASSES
#

# TODO separar em classes menores
class SkuSelector
	constructor: (productData) ->
		@productId = productData.productId
		@name = productData.name
		@dimensions = productData.dimensions
		@skus = productData.skus
		@uniqueDimensionsMap = productData.dimensionsMap

		#Create dimensions map
		@selectedDimensionsMap = {}
		@selectedDimensionsMap[dimension] = undefined for dimension in @dimensions

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


class SkuSelectorRenderer
	constructor: (context, selectors) ->
		@context = context

		# Build selectors from given select strings.
		@select = mapObj selectors, (key, val) ->
			( -> $(val, @context) )

		@select.itemDimension = (dimensionName) => $('.' + @generateItemDimensionClass(dimensionName), @context)
		@select.itemDimensionInput = (dimensionName) =>	$('.' + @generateItemDimensionClass(dimensionName) + ' input', @context)
		@select.itemDimensionLabel = (dimensionName) =>	$('.' + @generateItemDimensionClass(dimensionName) + ' label', @context)
		@select.itemDimensionValueInput = (dimensionName, valueName) =>	$('.' + @generateItemDimensionClass(dimensionName) + " input[value ='#{sanitize(valueName)}']", @context)
		@select.itemDimensionValueLabel = (dimensionName, valueName) =>	$('.' + @generateItemDimensionClass(dimensionName) + " label.skuespec_#{sanitize(valueName)}", @context)
			

	generateItemDimensionClass: (dimensionName) =>
		"item-dimension-#{sanitize(dimensionName)}"

	# Renders the DOM elements of the Sku Selector
	renderSkuSelector: (selector) =>
		dimensionIndex = 0

		image = selector.skus[0].image

		@context.find('.vtexsc-skuProductImage img').attr('src', image).attr('alt', selector.name)
		@context.find('.vtexsm-prodTitle').text(selector.name)

		# The order matters, because .skuListEach is inside .dimensionListsEach
		skuListBase = @context.find('.skuListEach').remove()
		dimensionListsBase = @context.find('.dimensionListsEach').remove()
		for dimension, dimensionValues of selector.uniqueDimensionsMap
			dimensionList = dimensionListsBase.clone()
			dimensionSanitized = sanitize(dimension)

			dimensionList.find('.specification').text(dimension)
			dimensionList.find('.topic').addClass("#{dimensionSanitized}").addClass(@generateItemDimensionClass(dimension))
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
					.attr('id', "#{selector.productId}_#{dimensionSanitized}_#{i}")
					.addClass(@generateItemDimensionClass(dimension))
					.addClass("sku-selector")
					.addClass("skuespec_#{valueSanitized}")
				skuList.find('label').text(value)
					.attr('for', "#{selector.productId}_#{dimensionSanitized}_#{i}")
					.addClass("dimension-#{dimensionSanitized}")
					.addClass("espec_#{dimensionIndex}")
					.addClass("skuespec_#{valueSanitized}")

				skuList.appendTo(dimensionList.find('.skuList'))

			dimensionList.appendTo(@context.find('.dimensionLists'))

	disableInvalidInputs: (selector) =>
		undefinedDimensions = selector.findUndefinedDimensions()
		selectableSkus = selector.findSelectableSkus()

		for dimension in undefinedDimensions
			# Disable all options in this row, add disabled class, remove checked class and matching removeAttr checked
			@select.itemDimensionInput(dimension)
				.addClass('item_unavaliable')
				.removeClass('checked sku-picked')
				.attr('disabled', 'disabled')
				.removeAttr('checked')
			@select.itemDimensionLabel(dimension)
				.addClass('disabled item_unavaliable')
				.removeClass('checked sku-picked')

			# Enable all selectable options in this row
			for value in selector.uniqueDimensionsMap[dimension]
				# Search for the sku dimension value corresponding to this dimension
				for sku in selectableSkus
					skuDimensionValue = sku.dimensions[dimension]
					# If the dimension value matches, enable the button
					if skuDimensionValue is value
						@select.itemDimensionValueInput(dimension, value).removeAttr('disabled')
					# If the dimension value matches and this sku is available, show as selectable
					if skuDimensionValue is value and sku.available
						@select.itemDimensionValueInput(dimension, value).removeClass('item_unavaliable')
						@select.itemDimensionValueLabel(dimension, value).removeClass('disabled item_unavaliable')

	selectDimension: (dimension) ->
		dimensions = @select.itemDimensionInput(dimension)
		# Tenta selecionar apenas dos disponíveis
		available = dimensions.filter('input:not(.item_unavaliable)')
		# Caso não haja indisponível, seleciona primeiro não-desabilitado (sku existente)
		el = (if available.length > 0 then available else dimensions).filter('input:enabled')[0]
		$(el).attr('checked', 'checked').change() if dimensions.length > 0

	updatePrice: (sku) ->
		if sku and sku.available
			@updatePriceAvailable(sku)
		else
			@updatePriceUnavailable()

	updatePriceAvailable: (sku) ->
		listPrice = formatCurrency sku.listPrice
		bestPrice = formatCurrency sku.bestPrice
		installments = sku.installments
		installmentValue = formatCurrency sku.installmentsValue

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

	applySelectedClasses: (dimensionName, dimensionValue) =>
		@select.itemDimensionInput(dimensionName).removeClass('checked sku-picked')
		@select.itemDimensionLabel(dimensionName).removeClass('checked sku-picked')
		@select.itemDimensionValueInput(dimensionName, dimensionValue).addClass('checked sku-picked')
		@select.itemDimensionValueLabel(dimensionName, dimensionValue).addClass('checked sku-picked')

	showWarnUnavailable: (sku) =>
		renderer.select.warnUnavailable().find('input#notifymeSkuId').val(sku)
		renderer.select.warnUnavailable().show()

#
# PLUGIN ENTRY POINT
#
$.fn.skuSelector = (productData, jsOptions = {}) ->
	this.addClass('sku-selector-loading')

	# Gather options
	domOptions = this.data()
	defaultOptions = $.fn.skuSelector.defaults
	# Build final options object (priority: js, then dom, then default)
	# Deep extending with true, for the selectors
	options = $.extend(true, defaultOptions, domOptions, jsOptions)

	# Instantiate our singletons
	selector = new SkuSelector(productData)
	renderer = new SkuSelectorRenderer(this, options.selectors)

	# Finds elements and puts SKU information in them
	renderer.renderSkuSelector(selector)

	# Initialize content disabling invalid inputs
	renderer.disableInvalidInputs(selector)

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
			renderer.select.warning().show().text('Por favor, escolha: ' + selector.findUndefinedDimensions()[0])
			return false

	# Handles changes in the dimension inputs
	dimensionChangeHandler = (event) ->
		dimensionName = $(this).attr('data-dimension')
		dimensionValue = $(this).attr('data-value')
		selector.setSelectedDimension(dimensionName, dimensionValue)
		selector.resetNextDimensions(dimensionName)
		selectedSku = selector.findSelectedSku()
		undefinedDimensions = selector.findUndefinedDimensions()

		renderer.select.warning().hide()
		renderer.select.warnUnavailable().filter(':visible').hide()

		# Trigger event for interested scripts
		if selectedSku isnt undefined and undefinedDimensions.length is 0
			$(this).trigger('skuSelected', [selectedSku, dimensionName])
			if options.warnUnavailable and not selectedSku.available
				renderer.showWarnUnavailable(selectedSku.sku)

		# Limpa classe de selecionado para todos dessa dimensao e coloca classes corretas em si
		renderer.applySelectedClasses(dimensionName, dimensionValue)

		renderer.disableInvalidInputs(selector)

		# Select first available dimensions
		if selectedSku
			for dimension in undefinedDimensions
				renderer.selectDimension(dimension)

		renderer.updatePrice(selectedSku)

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
		.click(buyButtonHandler)

	for dimension in selector.dimensions
		renderer.select.itemDimensionInput(dimension)
			.change(dimensionChangeHandler)

	if options.warnUnavailable
		renderer.select.warnUnavailable().find('form')
			.submit(warnUnavailableSubmitHandler)

	# Select first dimension
	if options.selectOnOpening or selector.findSelectedSku()
		renderer.selectDimension(selector.dimensions[0])

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
formatCurrency = (value) ->
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