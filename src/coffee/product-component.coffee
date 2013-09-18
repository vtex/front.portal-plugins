class ProductComponent
	bindProductEvent: (name, handler, productIdIndex = 0) =>
		$(window).on name, (evt, args...) =>
			return unless @productId is args[productIdIndex]
			handler(evt, args...)

	generateSelectors: (selectors) =>
		for k, v of selectors
			@["find#{k}"] = do(v) => => @element.find(v)
			@["show#{k}"] = do(k) => => @["find#{k}"]().show()
			@["hide#{k}"] = do(k) => => @["find#{k}"]().hide()

root = window || exports
root.ProductComponent = ProductComponent