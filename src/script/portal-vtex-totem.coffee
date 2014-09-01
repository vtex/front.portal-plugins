# DEPENDENCIES:
# jQuery
# jQuery.easyModal

$ = window.jQuery

$ ->
	# Barcode not found modal
	barCodeNotFoundText = "Código de barras não cadastrado"
	barCodeFoundText = "Adicionando produto ao carrinho..."
	if vtex?.i18n?.locale?
		if vtex.i18n.locale.indexOf('es') isnt -1
			barCodeNotFoundText = "Código de barras no registrado"
			barCodeFoundText = "Añadiendo producto al carrito..."
		else if vtex.i18n.locale.indexOf('en') isnt -1
			barCodeNotFoundText = "Barcode not registered"
			barCodeFoundText = "Adding product to cart..."

	$("#vtex-totem-barcode-not-found p").text(barCodeNotFoundText)
	$("#vtex-totem-barcode-found p").text(barCodeFoundText)
	$("#vtex-totem-barcode-not-found").easyModal()
	$("#vtex-totem-barcode-found").easyModal()

	# Barcode handler
	barCodeHandler = (barcode) ->
		$.ajax({
			url: '/api/catalog_system/pub/sku/stockkeepingunitByEan/'+barcode
		}).success (sku) ->
			$("#vtex-totem-barcode-found").trigger('openModal')
			$.ajax({
				url: '/api/catalog_system/pub/saleschannel/default'
			}).success (seller) ->
				if seller and seller.Id
					window.location = '/checkout/cart/add?sku='+sku.Id+'&qty=1&seller='+seller.Id+'&sc=1'
				else
					window.location = '/checkout/cart/add?sku='+sku.Id+'&qty=1&seller='+1+'&sc=1'
			.fail ->
				window.location = '/checkout/cart/add?sku='+sku.Id+'&qty=1&seller='+1+'&sc=1'
		.fail ->
			$("#vtex-totem-barcode-not-found").trigger('openModal')

	# Barcode listener
	isTypingBarcode = false
	barcode = ''
	$(document).on 'keydown.barcode', (e) ->
		value = String.fromCharCode(e.keyCode)
		if /\d/.test(value)
			barcode += value
			isTypingBarcode = true
		else
			if isTypingBarcode and barcode.length is 13 and /\t/.test(value)
				barCodeHandler(barcode)
			else
				isTypingBarcode = false
				barcode = ''

	return
