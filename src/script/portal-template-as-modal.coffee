KEYCODE_ESC = 27

getOverlay = ->
	template = '<div class="TB_overlay" style="display: none;"></div>'
	if (el = $(".TB_overlay")).length > 0 then el else $(template)

openModalFromTemplate = (evt) ->
	evt.preventDefault()
	templateURL = $(this).data("template")
	dataJSON = $(this).data("json")
	containerTemplate = """
		<div class="TB_window sku-selector">
			<div class="skuWrap_">
				Carregando...
			</div>
		</div>"""
	$overlay = getOverlay()
	$container = $(containerTemplate)

	$overlay.appendTo($("body")).fadeIn()
	$container.appendTo($("body")).fadeIn()

	hideModal = ->
		$overlay.fadeOut()
		$container.remove()
		$(document).off "click", hideModal

	hideModalOnEscapeKey = (e) ->
		if e.keyCode is KEYCODE_ESC
			hideModal()
			$(document).off "keyup", hideModalOnEscapeKey

	$overlay.on "click", hideModal
	$(document).on "keyup", hideModalOnEscapeKey

	$(window).on 'vtex.modal.hide', hideModal #DEPRECATED
	$(window).on 'modalHide.vtex', hideModal

	$.get(templateURL).done (content) ->
		$container.find('.skuWrap_').html('<div class="portal-sku-selector-ref"></div>')
		$.getJSON(dataJSON).done (data) ->
			$('.portal-sku-selector-ref').skuSelector(data, {modalLayout: true, warnUnavailable: true, redirect: false})
			$('.skuselector-buy-btn').buyButton(data.productId, {}, {giftRegistry: 1234});
			$('.skuselector-price').price(data.productId);

doBind = ->
	$('.to-bind-modal').each ->	$(this).removeClass('to-bind-modal').on('click', openModalFromTemplate)

$(document).ready(doBind)
$(document).on('ajaxComplete', doBind)
