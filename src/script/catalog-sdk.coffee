window.vtex or= {}
window.vtex.catalog or= {}

class CatalogSDK
	constructor: ->
		@BASE_ENDPOINT = '/api/catalog_system/pub'
		@cache = 
			productWithVariations: {}

	getShippingValue: (sku, postalCode, quantity=1) =>
		endpoint = "/frete/calcula/#{sku}"
		$.ajax
			type: 'GET'
			url: endpoint
			data: {shippinCep: postalCode, quantity: quantity}

	getProductWithVariations: (productId) =>
		$.when(@cache.productWithVariations[productId] or $.ajax("#{@BASE_ENDPOINT}/products/variations/#{productId}"))
			.done (response) =>
				@setProductWithVariationsCache(productId, response)

	setProductWithVariationsCache: (productId, apiResponse) =>
		@cache.productWithVariations[productId] = apiResponse

window.vtex.catalog.SDK = CatalogSDK
window.CATALOG_SDK = new CatalogSDK()