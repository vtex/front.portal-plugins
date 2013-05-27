skuVariationsDoneHandler = (options, json) ->
	$.skuSelector.$placeholder.removeClass('sku-selector-loading')
	unless json.dimensions.length is 0 and json.skus[0].available is false
		# Render the sku selector, passing the options with templates
		skuSelector = $.skuSelector.createSkuSelector(json.name, json.dimensions, json.skus, options)
		$.skuSelector.$placeholder.html(skuSelector)
		$.skuSelector.$placeholder.fadeIn()

addSkuToCart = (sku) ->  true

$(window).ready ->
	if $("meta[name=vtex-version]").length > 0
		productId = $('#product-id').val()
		$("#sku-selector-placeholder").skuSelector
			skuVariationsPromise: $.skuSelector.getSkusForProduct(productId)
			skuVariationsDoneHandler: skuVariationsDoneHandler
			addSkuToCart: addSkuToCart
			selectFirstAvailable: true

		$("#sku-selector-placeholder").on 'skuSelected', (e, sku, selectedDimension) -> console.log 'Selected:', sku, selectedDimension