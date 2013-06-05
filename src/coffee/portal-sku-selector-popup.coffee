# Called when we receive the json to render.
skuVariationsDoneHandler = (options, json) ->
	$.skuSelector.$placeholder.removeClass('sku-selector-loading')
	# If this item doesn't have variations, add it to the cart directly.
	if json.dimensions.length == 0
		return options.addSkuToCart json.skus[0].sku
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
	id = $(event.target).parents('li').find('h2').next().attr('id').replace('rating-produto-', '')
	# Opens the popup
	$.skuSelector.$placeholder.skuSelector
		skuVariationsPromise: $.skuSelector.getSkusForProduct(id)
		skuVariationsDoneHandler: skuVariationsDoneHandler
		addSkuToCart: addSkuToCart
		selectFirstAvailable: true
		productUrl: $(event.target).attr('href')
		mainTemplate: mainTemplate
		dimensionListTemplate: dimensionListTemplate
		skuDimensionTemplate: skuDimensionTemplate

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

mainTemplate = """
	<div class="vtex-plugin skuselector">
		<a href="javascript:void(0);" title="Fechar" class="skuselector-close">Fechar</a>
		<div class="skuselector-content">
			<div class="skuselector-title">Selecione a variação do produto:</div>
			<p class="skuselector-product-name">{{productName}}</p>
			<p class="skuselector-product-unavailable" style="display: none">
				Produto indisponível
			</p>
			<div class="skuselector-price" style="display:none;">
				<p class="skuselector-list-price">
					<span class="text">De: </span>
					<span class="value"></span>
				</p>
				<p class="skuselector-best-price">
					<span class="text">Por: </span>
					<span class="value"></span>
				</p>
				<p class="skuselector-installment"></p>
			</div>
			<div class="skuselector-sku">
				<p class="skuselector-image">
					<img src="{{image}}" width="160" height="160" alt="{{productAlt}}" />
				</p>
				<div class="skuselector-dimensions">
					{{dimensionLists}}
				</div>
				<p class="skuselector-warning"></p>
			</div>
			<div class="skuselector-buy-btn-wrap">
				<a href="javascript:void(0);" class="skuselector-buy-btn btn btn-success btn-large">Comprar</a>
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