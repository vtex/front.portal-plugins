$(window).ready ->
	$.skuSelector "popup" if $("meta[name=vtex-version]").length > 0

$(document).ajaxStop ->
	$.skuSelector.bindClickHandlers "btn-add-buy-button-asynchronous" if $("meta[name=vtex-version]").length > 0
