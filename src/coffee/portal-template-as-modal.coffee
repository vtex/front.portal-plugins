KEYCODE_ESC = 27

getOverlay = ->
	template = '<div class="boxPopUp2-overlay boxPopUp2-clickActive" style="display: none;"></div>'
	if (el = $(".boxPopUp2-overlay")).length > 0 then el else $(template)

openModalFromTemplate = (evt) ->
	templateURL = $(this).data("template")
	containerTemplate = """
		<div class="boxPopUp2 vtexsm-popupContent freeContentMain popupOpened sku-selector" style="position: fixed;">
			<div class="boxPopUp2-wrap">
				<div class="boxPopUp2-content vtexsm-popupContent freeContentPopup" style="position: fixed;">
					<div class="skuWrap_ freeContent vtexsc-selectSku">
						Carregando...
					</div>
				</div>
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

	$(window).on 'vtex.modal.hide', hideModal

	$.get(templateURL).done (content) ->
		$container.find('.skuWrap_').html $(content)

doBind = ->
	$('.to-bind-modal').each ->	$(this).removeClass('to-bind-modal').on('click', openModalFromTemplate)

$(document).ready(doBind)
$(document).on('ajaxComplete', doBind)