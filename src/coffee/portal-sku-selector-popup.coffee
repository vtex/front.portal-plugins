# Called when we receive the json to render.
skuVariationsDoneHandler = ($el, options, json) ->
	$el.removeClass('sku-selector-loading')
	# If this item doesn't have variations, add it to the cart directly.
	if json?.dimensions?.length == 0
		return options.addSkuToCart json.skus[0].sku
	else
		# Render the sku selector, passing the options with templates
		skuSelector = $.skuSelector.createSkuSelector(json.productId, json.name, json.dimensions, json.dimensionsMap, json.skus, options, $el)
		$el.html(skuSelector)
		$.skuSelectorPopup.showPopup()

# Adds a given sku to the cart. On success, shows the mini-cart
# On failure, redirects the user to the cart.
addSkuToCart = (sku) ->
	$.skuSelectorPopup.hidePopup()
	# console.log 'Adding SKU to cart:', sku
	promise = $.get $.skuSelector.getAddUrlForSku(sku, 1, 1, false)
	promise.done (data) ->
		$(window).trigger 'productAddedToCart'
		# console.log 'Item adicionado com sucesso', sku, data
	promise.fail (jqXHR, status) ->
		# console.log jqXHR?.status, status
		# console.log 'Erro ao adicionar item', sku
		window.location.href = $.skuSelector.getAddUrlForSku(sku)
	return false

# An utilitary function to bind element's with the given class.
# The class will be removed from the element.
# You should use a "disposable" class, such as "add-buy-button".
bindClickHandlers = (className, $el) ->
	$elements = $('.'+className)
	warnUnavailable = $elements.data('warnUnavailable')
	selectOnOpening = $elements.data('selectOnOpening')
	# console.log 'Binding to', $elements.length
	$elements.removeClass className
	$elements.click (event) ->
		event.preventDefault()
		id = $(event.target).data('product-id')
		# Opens the popup
		$($el).skuSelector
			skuVariationsPromise: $.skuSelector.getSkusForProduct(id)
			skuVariationsDoneHandler: skuVariationsDoneHandler
			addSkuToCart: addSkuToCart
			productUrl: $(event.target).attr('href')
			mainTemplate: mainTemplate
			dimensionListTemplate: dimensionListTemplate
			skuDimensionTemplate: skuDimensionTemplate
			warnUnavailable: warnUnavailable
			selectOnOpening: selectOnOpening

mainTemplate = """
	<div class="boxPopUp2-wrap">
		<span class="boxPopUp2-close boxPopUp2-clickActive sku-selector-sku"></span>
		<div class="boxPopUp2-content vtexsm-popupContent freeContentPopup" style="position: fixed;">
			<div class="skuWrap_ freeContent vtexsc-selectSku">
				<div class="selectSkuTitle">
					Selecione a variação do produto
				</div>
				<div class="vtexsm-prodTitle">{{productName}}</div>
				<div class="vtexsc-skusWrap">
					<div class="vtexsc-skuProductImage">
						<img src="{{image}}" width="160" height="160" alt="{{productAlt}}" />
					</div>
					<div class="skuListWrap_">
						{{dimensionLists}}
					</div>
					<div class="vtexsc-skuProductPrice skuselector-price" style="display: none;">
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
				<div class="skuselector-warn-unavailable" style="display: none;">
					<form action="">
						<fieldset class="notifyme-form" style="display: block;">
							<p>
									Para ser avisado da disponibilidade deste Produto, basta preencher os campos abaixo.
							</p>
							<input id="notifymeClientName" class="notifyme-client-name" placeholder="Digite seu nome..." size="20" type="text" name="notifymeClientName">
							<input id="notifymeClientEmail" class="notifyme-client-email" placeholder="Digite seu e-mail..." size="20" type="text" name="notifymeClientEmail">
							<input id="notifymeButtonOK" class="btn-ok notifyme-button-ok" value="ok" type="submit" name="notifymeButtonOK">
							<input id="notifymeSkuId" type="hidden" class="notifyme-skuid" name="notifymeIdSku" value="">
					</fieldset>
					</form>
					<span id="notifymeLoading" class="notifyme-success"  style="display: none">Carregando...</span>
					<span id="notifymeSuccess" class="notifyme-success"  style="display: none">Cadastrado com sucesso, assim que o produto for disponibilizado você receberá um email avisando.</span>
					<span id="notifymeError" class="notifyme-error" style="display: none">Não foi possível cadastrar. Tente mais tarde.</span>
				</div>
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
		class="skuselector-specification-label input-dimension-{{dimensionSanitized}} sku-selector skuespec_{{valueSanitized}} change-image" id="{{productId}}_{{dimensionSanitized}}_{{index}}" value="{{valueSanitized}}" specification="{{valueSanitized}}">
	<label for="{{productId}}_{{dimensionSanitized}}_{{index}}" class="dimension-{{dimensionSanitized}} espec_{{dimensionIndex}} skuespec_{{valueSanitized}} skuespec_{{dimensionSanitized}}_opcao_{{valueSanitized}}">{{value}}</label>
	"""

#
# SkuSelector Popup Creator.
#

# Usage example:
# $popup = $.skuSelectorPopup({popupId: "id", popupClass: "class1 class2"});
$.skuSelectorPopup = (options = {}) ->
	opts = $.extend($.skuSelectorPopup.defaults, options)
	# console.log('skuSelector', opts)

	$.skuSelectorPopup.$overlay = $(opts.overlayTemplate)
	$.skuSelectorPopup.$overlay.addClass(opts.overlayClass) if opts.overlayClass
	$.skuSelectorPopup.$overlay.attr('id', opts.overlayId) if opts.overlayId
	$el = $(opts.popupTemplate)
	$el.addClass(opts.popupClass) if opts.popupClass
	$el.attr('id', opts.popupId) if opts.popupId

	$('body').append($.skuSelectorPopup.$overlay) # Adds the overlay
	$('body').append($el) # Adds the placeholder

	# Adds show function
	$.skuSelectorPopup.showPopup = ->
		$.skuSelectorPopup.$overlay?.fadeIn()
		$el?.fadeIn()

	# Adds hide function
	$.skuSelectorPopup.hidePopup = ->
		$.skuSelectorPopup.$overlay?.fadeOut()
		$el?.fadeOut()

	# Hide the popup on overlay click
	$.skuSelectorPopup.$overlay.click $.skuSelectorPopup.hidePopup

	# Binds the exit handler
	$el.on 'click', '.skuselector-close', ->
		$.skuSelectorPopup.hidePopup()
		# console.log 'Exiting sku selector'

	return $el

$.skuSelectorPopup.defaults =
	popupTemplate: '<div class="boxPopUp2 vtexsm-popupContent freeContentMain popupOpened" style="display: none;"></div>'
	overlayTemplate: '<div class="boxPopUp2-overlay boxPopUp2-clickActive" style="display: none;"></div>'
	overlayId: 'sku-selector-overlay'
	overlayClass: undefined
	popupId: 'sku-selector-popup'
	popupClass: 'sku-selector'

popup = {}

$(document).ready ->
	popup = $.skuSelectorPopup()
	# popup.on 'skuSelected', (e, sku, dimension) -> # console.log 'skuSelected', sku, dimension
	bindClickHandlers "btn-add-sku", popup

$(document).ajaxStop ->
	bindClickHandlers "btn-add-sku", popup