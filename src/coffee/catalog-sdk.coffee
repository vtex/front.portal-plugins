window.vtex or= {}
window.vtex.catalog or= {}

class CatalogSDK
	constructor: ->
		@BASE_ENDPOINT = '/api/catalog_system/pub'
		@cache = 
			productWithVariations: {}

#		@methods =
#			[
#				name: 'productWithVariations'
#				endpoint: "#{@BASE_ENDPOINT}/products/variations/:arg"
#				cacheAjaxResponse: true
#			]
#
#		for method in @methods
#			capitalize = -> str.charAt(0).toUpperCase() + str.substring(1)
#			capitalizedName = capitalize(method.name)
#			@["set#{capitalizedName}Cache"] = do(method) => (arg, response) =>
#				@cache[method.name][arg] = response
#			@["get#{capitalizedName}"] = do(method) => (arg) =>
#				$.when(@cache[method.name][arg] or $.ajax(method.endpoint.replace(':arg', arg)))
#					.done (response) =>
#						@["set#{capitalizedName}Cache"](arg, response)

	getProductWithVariations: (productId) =>
		$.when(@cache.productWithVariations[productId] or $.ajax("#{@BASE_ENDPOINT}/products/variations/#{productId}"))
			.done (response) =>
				@setProductWithVariationsCache(productId, response)

	setProductWithVariationsCache: (productId, apiResponse) =>
		@cache.productWithVariations[productId] = apiResponse

window.vtex.catalog.SDK = CatalogSDK
window.CATALOG_SDK = new CatalogSDK()