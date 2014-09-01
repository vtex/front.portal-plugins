root = window || exports
root.EVENT_HISTORY or= {}

class ProductComponent
	bindProductEvent: (name, handler, productIdIndex = 0) =>
		bindProductId = (name, handler, productId) =>
			$(window).on name, (evt, args...) =>
				evtProductId = args[productIdIndex]
				return unless productId is evtProductId
				handler(evt, args...)

			if EVENT_HISTORY[productId]?[name]?
				handler(EVENT_HISTORY[productId][name]...)

		if @options.multipleProductIds
			for productId in @productId
				bindProductId(name, handler, productId)
		else
			bindProductId(name, handler, @productId)

	triggerProductEvent: (name, args...) =>
		element = @element or ($window)
		evt = jQuery.Event(name)
		args2 = [@productId, args...]

		element.trigger evt, args2
		EVENT_HISTORY[@productId] or= {}
		EVENT_HISTORY[@productId][name] = [evt, args2...]

	generateSelectors: (selectors) =>
		for k, v of selectors
			if typeof v is 'function'
				@["find#{k}"] = v
			else
				@["find#{k}"] = do(v) => => @element.find(v)
			@["findFirst#{k}"] = do(k) => => $(@["find#{k}"]()[0])
			@["show#{k}"] = do(k) => => @["find#{k}"]().show()
			@["hide#{k}"] = do(k) => => @["find#{k}"]().hide()

		@showAll = do(selectors) => => @["show#{k}"]() for k, v of selectors
		@hideAll = do(selectors) => => @["hide#{k}"]() for k, v of selectors

root.ProductComponent = ProductComponent