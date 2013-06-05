skuVariationsDoneHandler = (options, json) ->
	$.skuSelector.$placeholder.removeClass('sku-selector-loading')
	unless json.dimensions.length is 0 and json.skus[0].available is false
		# Render the sku selector, passing the options with templates
		skuSelector = $.skuSelector.createSkuSelector(json.name, json.dimensions, json.skus, options)
		$.skuSelector.$placeholder.html(skuSelector)
		$.skuSelector.$placeholder.fadeIn()

addSkuToCart = (sku) ->  true

$(".skuTamanho").html('').hide().addClass('sku-selector-container');

$(window).ready ->
	if $("meta[name=vtex-version]").length > 0
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
			#window.FireSkuChangeImage?(sku.sku)
			#window.FireSkuDataReceived?(sku.sku)
			#window.FireSkuSelectionChanged?(sku.sku)

mainTemplate = """
	<div class="vtex-plugin skuselector">
		<div class="skuselector-content">
			<div class="skuselector-title">Selecione a variação do produto:</div>
			<p class="skuselector-product-unavailable" style="display: none">
				Produto indisponível
			</p>
			<div class="skuselector-sku">
				<div class="skuselector-dimensions">
					{{dimensionLists}}
				</div>
				<p class="skuselector-warning"></p>
			</div>
		</div>
	</div>
	"""

dimensionListTemplate = """
	<div class="dimension dimension-{{dimensionIndex}} dimension-{{dimensionSanitized}}">
		<p class="skuselector-specification">
			{{dimension}}
		</p>
		<ul class="skuselector-sepecification-list unstyled">
			{{skuList}}
		</ul>
	</div>
	"""

skuDimensionTemplate = """
	<li class="skuselector-specification-item item-dimension-{{dimensionSanitized}} item-spec-{{index}} item-dimension-{{dimensionSanitized}}-spec-{{index}}">
		<input type="radio" name="dimension-{{dimensionSanitized}}" dimension="{{dimensionSanitized}}" data-value="{{value}}" data-dimension="{{dimension}}"
			class="skuselector-specification-label input-dimension-{{dimensionSanitized}}" id="dimension-{{dimensionSanitized}}-spec-{{index}}" value="{{valueSanitized}}">
		<label for="dimension-{{dimensionSanitized}}-spec-{{index}}" class="dimension-{{dimensionSanitized}}">{{value}}</label>
	</li>
	"""

updateBuyButtonURL = (url)->
	$('.buy-button').attr('href', url)