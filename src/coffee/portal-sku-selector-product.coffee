skuVariationsDoneHandler = (options, json) ->
	$.skuSelector.$placeholder.removeClass('sku-selector-loading')
	unless json.dimensions.length is 0 and json.skus[0].available is false
		# Render the sku selector, passing the options with templates
		skuSelector = $.skuSelector.createSkuSelector(json.name, json.dimensions, json.skus, options)
		$.skuSelector.$placeholder.html(skuSelector)
		$.skuSelector.$placeholder.fadeIn()
		$('body').trigger('skuSelectorReady')

addSkuToCart = (sku) ->  true

$(".skuTamanho").html('').hide().addClass('sku-selector-container');

$(window).ready ->
	$(".skuTamanho").html('').hide().addClass('sku-selector-container');

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
	<ul class="topic {{dimensionSanitized}} item-dimension-{{dimensionSanitized}}">
		<li class="specification">{{dimension}}</li>
		<li class="select skuList">
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