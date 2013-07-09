KEYCODE_ESC = 27

doBind = ->
	$('.to-bind-modal').each ->	$(this).removeClass('to-bind-modal').on('click', openModalFromTemplate)

getOverlay = ->
	template = '<div class="boxPopUp2-overlay boxPopUp2-clickActive" style="display: none;"></div>'
	if (el = $(".boxPopUp2-overlay")).length > 0 then el else $(template)

openModalFromTemplate = (evt) ->
	templateURL = $(this).data("template")
	containerTemplate = """
		<div class="boxPopUp2 vtexsm-popupContent freeContentMain popupOpened sku-selector" style="position: fixed;">
			<div class="boxPopUp2-wrap">
				<div class="boxPopUp2-content vtexsm-popupContent freeContentPopup" style="position: fixed;">
					Loading...
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
	hideModalOnEscapeKey = (e) ->
		hideModal() if e.keyCode is KEYCODE_ESC
		$(document).off "keyup", hideModalOnEscapeKey

	$overlay.on "click", hideModal
	$(document).on "keyup", hideModalOnEscapeKey

	$.get(templateURL).done (content) ->
		$container.html $(content)

$(document).ready(doBind)
$(document).on('ajaxComplete', doBind)