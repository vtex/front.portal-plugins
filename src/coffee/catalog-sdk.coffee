window.vtex or= {}
window.vtex.catalog or= {}

class CatalogSDK
	constructor: ->
		@BASE_ENDPOINT = '/api/catalog_system/pub'
		@cache = 
			productWithVariations: {}

	getProductWithVariations: (productId) ->
		if @cache.productWithVariations[productId]?
			return @cache.productWithVariations[productId]
		else
			console?.log?('Non-cached information -- not supported')
			return null

	setProductWithVariationsCache: (productId, apiResponse) ->
		@cache.productWithVariations[productId] = apiResponse

window.vtex.catalog.SDK = CatalogSDK
window.CATALOG_SDK = new CatalogSDK()