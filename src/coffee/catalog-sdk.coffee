window.vtex or= {}
window.vtex.catalog or= {}

class CatalogSDK
	constructor: ->
		@BASE_ENDPOINT = '/api/catalog_system/pub'
		@cache = 
			productWithVariations: {}

	getProductWithVariations: (productId) =>
		return $.when(@cache.productWithVariations[productId] or $.ajax("#{@BASE_ENDPOINT}/products/variations/#{productId}"))

	setProductWithVariationsCache: (productId, apiResponse) =>
		@cache.productWithVariations[productId] = apiResponse

window.vtex.catalog.SDK = CatalogSDK
window.CATALOG_SDK = new CatalogSDK()