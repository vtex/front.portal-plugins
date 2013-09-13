class ProductComponent
	bindProductEvent: (name, handler, productIdIndex = 0) =>
		$(window).on name, (evt, args...) =>
			return unless @productId is args[productIdIndex]
			handler(evt, args...)

root = window || exports
root.ProductComponent = ProductComponent