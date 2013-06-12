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
		$(window).trigger 'cartUpdated'
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

mainTemplate = """
	<div class="boxPopUp2-wrap">
		<span class="boxPopUp2-close boxPopUp2-clickActive sku-selector-sku"></span>
		<div class="boxPopUp2-content vtexsm-popupContent freeContentPopup" style="position: fixed;">
			<div class="skuWrap_ freeContent vtexsc-selectSku">
				<div class="selectSkuTitle">
					Selecione a variação do produto
				</div>
				<div class="vtexsm-prodTitle">{{productName}}</div>
				<p class="skuselector-product-unavailable" style="display: none">Produto indisponível</p>
				<div class="vtexsc-skusWrap">
					<div class="vtexsc-skuProductImage">
						<img src="{{image}}" width="160" height="160" alt="{{productAlt}}" />
					</div>
					<div class="skuListWrap_">
						{{dimensionLists}}
					</div>
					<div class="vtexsc-skuProductPrice skuselector-price">
						<div class="regularPrice skuselector-list-price">
							De: <span class="value"></span>
						</div>
						<div class="newPrice skuselector-best-price">
							Por: <span class="value"></span>
						</div>
						<div class="installment"></div>
					</div>
				</div>
				<p class="skuselector-warning" style="display: none;"></p>
				<div class="vtexsc-buttonWrap clearfix skuselector-buy-btn-wrap">
					<a href="#" class="vtexsc-buyButton skuselector-buy-btn"></a>
				</div>
			</div>
		</div>
	</div>
	"""

dimensionListTemplate = """
	<ul class="topic {{dimensionSanitized}} item-dimension-{{dimensionSanitized}}">
		<li class="specification">{{dimension}}</li>
		<li class="select skuList">
			<span class="group_{{dimensionIndex}}">{{skuList}}</span>
		</li>
	</ul>
	"""

skuDimensionTemplate = """
	<input type="radio" name="dimension-{{dimensionSanitized}}" dimension="{{dimensionSanitized}}" data-value="{{value}}" data-dimension="{{dimension}}"
		class="skuselector-specification-label input-dimension-{{dimensionSanitized}} sku-selector skuespec_{{valueSanitized}} change-image" id="espec_{{dimensionIndex}}_opcao_{{index}}" value="{{valueSanitized}}" specification="{{valueSanitized}}">
	<label for="espec_{{dimensionIndex}}_opcao_{{index}}" class="dimension-{{dimensionSanitized}} espec_{{dimensionIndex}} skuespec_{{valueSanitized}}">{{value}}</label>
	"""

#
# SkuSelector Popup Creator.
#

# Usage example:
# $popup = $.skuSelectorPopup({popupId: "id", popupClass: "class1 class2"});
$.skuSelectorPopup = (options = {}) ->
	opts = $.extend($.skuSelectorPopup.defaults, options)
	console.log('skuSelector', opts)

	$.skuSelector.$overlay = $(opts.overlayTemplate)
	$.skuSelector.$overlay.addClass(opts.overlayClass) if opts.overlayClass
	$.skuSelector.$overlay.attr('id', opts.overlayId) if opts.overlayId
	$.skuSelector.$placeholder = $(opts.popupTemplate)
	$.skuSelector.$placeholder.addClass(opts.popupClass) if opts.popupClass
	$.skuSelector.$placeholder.attr('id', opts.popupId) if opts.popupId

	$('body').append($.skuSelector.$overlay) # Adds the overlay
	$('body').append($.skuSelector.$placeholder) # Adds the placeholder

	# Adds show function
	$.skuSelector.$placeholder.showPopup = ->
		$.skuSelector.$overlay?.fadeIn()
		$.skuSelector.$placeholder?.fadeIn()

	# Adds hide function
	$.skuSelector.$placeholder.hidePopup = ->
		$.skuSelector.$overlay?.fadeOut()
		$.skuSelector.$placeholder?.fadeOut()

	# Hide the popup on overlay click
	$.skuSelector.$overlay.click $.skuSelector.$placeholder.hidePopup

	# Binds the exit handler
	$.skuSelector.$placeholder.on 'click', '.skuselector-close', ->
		$.skuSelector.$placeholder.hidePopup()
		console.log 'Exiting sku selector'

	return $.skuSelector.$placeholder

$.skuSelectorPopup.defaults =
	popupTemplate: '<div class="boxPopUp2 vtexsm-popupContent freeContentMain popupOpened" style="display: none;"></div>'
	overlayTemplate: '<div class="boxPopUp2-overlay boxPopUp2-clickActive"></div>'
	overlayId: 'sku-selector-overlay'
	overlayClass: undefined
	popupId: 'sku-selector-popup'
	popupClass: 'sku-selector'

$(window).ready ->
	$.skuSelectorPopup() if $("meta[name=vtex-version]").length > 0

$(document).ajaxStop ->
	bindClickHandlers "btn-add-buy-button-asynchronous" if $("meta[name=vtex-version]").length > 0