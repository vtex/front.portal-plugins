$(document).on "dimensionChanged", ->
	$(".notifyme").hide()
	$(".buy-button").hide()

$(document).on "skuSelected", (evt, sku) ->
	console.log "Foi selecionado um sku que está " + (if sku.available then "" else "un") + "available: ", sku
	if sku.available
		$(".buy-button").show()
		$(".skuBestPrice").text "R$ " + $.formatCurrency(sku.bestPrice)
		# etc...
	else
		$(".notifyme").show()
		# etc...