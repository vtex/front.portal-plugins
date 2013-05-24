if $("meta[name=vtex-version]").length > 0
	$('.buy-button').hide()
	$('.descricao-preco').hide()
	$(".skuTamanho").html('').hide()

$(window).ready ->
	if $("meta[name=vtex-version]").length > 0
		endpoint = '/api/catalog_system/pub/products/variations/';
		productId = $('#___rc-p-id').val()
		skuVariationsDoneHandler = (options, json) ->
			$.skuSelector.$placeholder.removeClass('sku-selector-loading')
			unless json.dimensions.length is 0 and json.skus[0].available is false
				# Render the sku selector, passing the options with templates
				skuSelector = $.skuSelector.createSkuSelector(json.name, json.dimensions, json.skus, options)
				$.skuSelector.$placeholder.html(skuSelector)
				$.skuSelector.$placeholder.fadeIn()

		addSkuToCart = (sku) ->  true

		$(".skuTamanho").skuSelector
			skuVariationsPromise: $.get(endpoint + productId)
			skuVariationsDoneHandler: skuVariationsDoneHandler
			addSkuToCart: addSkuToCart
			selectFirstAvailable: true

		$(".skuTamanho").on 'skuSelected', (e, sku, selectedDimension) -> console.log 'Selected:', sku, selectedDimension