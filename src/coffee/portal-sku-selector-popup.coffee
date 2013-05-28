# Called when we receive the json to render.
skuVariationsDoneHandler = (options, json) ->
	$.skuSelector.$placeholder.removeClass('sku-selector-loading')
	# If this item doesn't have variations, add it to the cart directly.
	if json.dimensions.length == 0
		options.addSkuToCart json.skus[0].sku
	else
		# Render the sku selector, passing the options with templates
		skuSelector = $.skuSelector.createSkuSelector(json.name, json.dimensions, json.skus, options)
		$.skuSelector.$placeholder.html(skuSelector)
		$.skuSelector.$placeholder.showPopup?()

# Adds a given sku to the cart. On success, shows the mini-cart
# On failure, redirects the user to the cart.
addSkuToCart = (sku) ->
	$.skuSelector.$placeholder.hidePopup?()
	console.log 'Adding SKU to cart:', sku
	promise = $.get $.skuSelector.getAddUrlForSku(sku, 1, 1, false)
	promise.done (data) ->
		vtexMinicartShowMinicart() if window.vtexMinicartShowMinicart
		console.log 'Item adicionado com sucesso', sku, data
	promise.fail (jqXHR, status) ->
		console.log jqXHR?.status, status
		console.log 'Erro ao adicionar item', sku
		window.location.href = $.skuSelector.getAddUrlForSku(sku)
	return false

# A sample buy button click handler
# You can use it as a default with the popup flavor of the sku selector.
buyButtonClickHandler = (event) ->
	event.preventDefault()
	id = $(event.target).data('product-id')
	# Opens the popup
	$.skuSelector.$placeholder.skuSelector(
		skuVariationsPromise: $.skuSelector.getSkusForProduct(id)
		skuVariationsDoneHandler: skuVariationsDoneHandler
		addSkuToCart: addSkuToCart
		selectFirstAvailable: true
		productUrl: $(event.target).attr('href')
	)
	return false

# An utilitary function to bind element's with the given class.
# The class will be removed from the element.
# You should use a "disposable" class, such as "add-buy-button".
bindClickHandlers = (className) ->
	$elements = $('.'+className)
	console.log 'Binding to', $elements.length
	$elements.removeClass className
	$elements.click buyButtonClickHandler

$(window).ready ->
	$.skuSelector "popup" if $("meta[name=vtex-version]").length > 0

$(document).ajaxStop ->
	bindClickHandlers "btn-add-buy-button-asynchronous" if $("meta[name=vtex-version]").length > 0
