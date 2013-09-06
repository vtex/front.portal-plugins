class ProductComponent
	getProductEvent: (name, handler, productIdIndex = 0) =>
		$(window).on name, (evt, args...) =>
			return unless @productId == args[productIdIndex]
			handler(evt, args...)
