skuVariationsDoneHandler = ($el, options, json) ->
	$el.removeClass('sku-selector-loading')
	unless json.dimensions.length is 0 and json.skus[0].available is false
		# Render the sku selector, passing the options with templates
		skuSelector = $.skuSelector.createSkuSelector(json.name, json.dimensions, json.skus, options, $el)
		$el.html(skuSelector)
		$el.fadeIn()
		$('body').trigger('skuSelectorReady')

addSkuToCart = (sku) ->  true

ref = $('.product-sku-selector-ref');
ref.after('<div class="sku-selector-container" />');
ref.remove();

$(window).ready ->
	ref = $('.product-sku-selector-ref');
	ref.after('<div class="sku-selector-container" />');
	ref.remove();

	productId = $('#___rc-p-id').val()
	$(".sku-selector-container").skuSelector
		skuVariationsPromise: $.skuSelector.getSkusForProduct(productId)
		skuVariationsDoneHandler: skuVariationsDoneHandler
		addSkuToCart: addSkuToCart
		selectFirstAvailableOnStart: true
		mainTemplate: mainTemplate
		dimensionListTemplate: dimensionListTemplate
		skuDimensionTemplate: skuDimensionTemplate
		updateBuyButtonURL: updateBuyButtonURL

	$(".sku-selector-container").on 'skuSelected', (e, sku, selectedDimension) ->
		console.log 'Selected:', sku, selectedDimension
		window.FireSkuChangeImage?(sku.sku)
		#window.FireSkuDataReceived?(sku.sku)
		window.FireSkuSelectionChanged?(sku.sku)

mainTemplate = """{{dimensionLists}}"""

dimensionListTemplate = """
	<ul class="topic {{dimensionSanitized}}">
		<li class="specification">{{dimension}}</li>
		<li class="select skuList item-dimension-{{dimensionSanitized}}">
			<span class="group_{{dimensionIndex}}">
				{{skuList}}
			</span>
		</li>
	</ul>
	"""

skuDimensionTemplate = """
	<input type="radio" name="dimension-{{dimensionSanitized}}" dimension="{{dimensionSanitized}}" data-value="{{value}}" data-dimension="{{dimension}}"
		class="skuselector-specification-label input-dimension-{{dimensionSanitized}} sku-selector skuespec_{{valueSanitized}} change-image" id="espec_{{dimensionIndex}}_opcao_{{index}}" value="{{valueSanitized}}" specification="{{valueSanitized}}">
	<label for="espec_{{dimensionIndex}}_opcao_{{index}}" class="dimension-{{dimensionSanitized}} espec_{{dimensionIndex}} skuespec_{{valueSanitized}}">{{value}}</label>
	"""

updateBuyButtonURL = (url)->
	$('.buy-button').attr('href', url)