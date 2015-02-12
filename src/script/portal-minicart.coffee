# DEPENDENCIES:
# jQuery
# vtex-utils
# dust

$ = window.jQuery

# CLASS
class Minicart
	constructor: (@element, @options) ->
		@EXPECTED_ORDER_FORM_SECTIONS = ["items", "paymentData", "totalizers", "shippingData", "sellers"]

		@hoverContext = @element.add('.show-minicart-on-hover')
		@cartData = {}

		@base = $('.minicartListBase').remove()

		@select =
			amountProducts: => $('.amount-products-em', @element)
			amountItems: => $('.amount-items-em', @element)
			totalCart: => $('.total-cart-em', @element)

		@startHelpers()
		@bindEvents()
		@updateCart(false)

		$(window).trigger "minicartLoaded"

	startHelpers: =>
		dust.helpers.formatDate = (chunk, context, bodies, params) ->
			timestamp = params.date
			return chunk.write(formatDate(timestamp))

		dust.helpers.formatMoment = (chunk, context, bodies, params) ->
			timestamp = params.date
			return chunk.write(formatMoment(timestamp))

		dust.helpers.cond_write = (chunk, context, bodies, params) ->
			if params.key == params.value
				return bodies.block(chunk, context)
			else
				return bodies.else(chunk, context)

	formatMoment = (timestamp) =>
		date = new Date(timestamp)
		utcDate = date.toUTCString()
		moment = utcDate.match(/\d\d:\d\d:\d\d/)[0]
		momentArray = moment.split(':')
		hour = momentArray[0]
		minutes = momentArray[1]
		return "#{hour}:#{minutes}"

	formatDate = (timestamp) =>
		weekDaysTranslationMap =
			"Sun": "Domingo"
			"Mon": "Segunda-feira"
			"Tue": "Terça-feira"
			"Wed": "Quarta-feira"
			"Thu": "Quinta-feira"
			"Fri": "Sexta-feira"
			"Sat": "Sábado"

		monthsTranslationMap =
			"Jan": "Janeiro"
			"Feb": "Fevereiro"
			"Mar": "Março"
			"Apr": "Abril"
			"May": "Maio"
			"Jun": "Junho"
			"Jul": "Julho"
			"Aug": "Agosto"
			"Sep": "Setembro"
			"Oct": "Outubro"
			"Nov": "Novembro"
			"Dec": "Dezembro"

		date = new Date(timestamp)
		dateInfo = date.toString().split(' ')
		weekDay = dateInfo[0]
		ptWeekDay = weekDaysTranslationMap[weekDay]
		month = dateInfo[1]
		ptMonth = monthsTranslationMap[month]
		day = dateInfo[2]
		year = dateInfo[3]

		return "#{ptWeekDay}, #{day} de #{ptMonth} de #{year}"

	getOrderFormURL: =>
 		@options.orderFormURL

	getOrderFormUpdateURL: =>
		@getOrderFormURL() + @cartData.orderFormId + "/items/update/"

	bindEvents: =>
		@hoverContext.on 'mouseover', =>
			$(window).trigger "minicartMouseOver" #DEPRECATED
			@element.trigger 'vtex.minicart.mouseOver' #DEPRECATED
			$(window).trigger "minicartMouseOver.vtex"

		@hoverContext.on 'mouseout', =>
			$(window).trigger "minicartMouseOut" #DEPRECATED
			@element.trigger 'vtex.minicart.mouseOut' #DEPRECATED
			$(window).trigger "minicartMouseOut.vtex"

		$(window).on "minicartMouseOver.vtex", =>
			if @cartData.items?.length > 0
				$(".vtexsc-cart").slideDown()
				clearTimeout @timeoutToHide

		$(window).on "minicartMouseOut.vtex", =>
			clearTimeout @timeoutToHide
			@timeoutToHide = setTimeout ->
				$(".vtexsc-cart").stop(true, true).slideUp()
			, 800

		$(window).on "cartUpdated", (evt, args...) => @updateCart(args...)
		$(window).on 'cartProductAdded.vtex', (evt, args...) => @updateCart(args...)
		$(window).on 'cartProductRemoved.vtex', (evt, args...) => @updateCart(args...)
		$(window).on 'orderFormUpdated.vtex', (evt, args...) => @handleOrderForm(args...)

	updateCart: (slide = true) =>
		@element.addClass 'amount-items-in-cart-loading'

		vtexjs.checkout.getOrderForm(@EXPECTED_ORDER_FORM_SECTIONS)
			.done (data) =>
				@element.removeClass 'amount-items-in-cart-loading'
				@element.trigger 'vtex.minicart.updated' #DEPRECATED
				@element.trigger 'minicartUpdated.vtex'
				@handleOrderForm(data, slide)

	handleOrderForm: (orderForm) =>
		@cartData.orderFormId = orderForm?.orderFormId
		@cartData.totalizers = orderForm?.totalizers
		@cartData.shippingData = orderForm?.shippingData
		@cartData.sellers = orderForm?.sellers
		if orderForm?.items?
			@cartData.items = orderForm.items
			@setupMinicart()

	setupMinicart: (slide = true) =>
		@prepareCart()
		@setDeliveryOptionsSelectorsState() if @cartData.showShippingOptions
		@render()
		@slide() if slide


	setTimetablesSelectorOptions: (selectedDate) =>

		availableTimetables = $('.available-timetables')

		timetablesList = _.toArray _.filter _this.cartData.deliveryWindows, (dw) ->
			date = new Date(dw.startDateUtc)
			return date.getDate() is selectedDate.getDate()

		availableTimetables.empty()

		_.each timetablesList, (timetable, index) ->
			startTime = formatMoment(timetable.startDateUtc)
			endTime = formatMoment(timetable.endDateUtc)
			text = "Das #{startTime} às #{endTime}"
			optionNode = $("<option>").text(text).val(timetable.startDateUtc)
			availableTimetables.append(optionNode)

	setDeliveryOptionsSelectorsState: =>
		return unless @cartData.shippingData?.logisticsInfo?.length > 0

		logisticsInfo = @cartData.shippingData.logisticsInfo

		if logisticsInfo[0].selectedSla?
			selectedSla = _.find @cartData.slas, (sla) ->
				return sla.name == logisticsInfo[0].selectedSla

			selectedSla.isSelected = true
			@cartData.selectedSla = selectedSla

			if selectedSla.deliveryWindow?
				@cartData.isScheduledSla = true
				@cartData.availableDeliveryWindows = selectedSla.availableDeliveryWindows

				selectedDay = selectedSla.deliveryWindow.startDateUtc
				@cartData.selectedDay = _.find @cartData.availableDays, (availableDay) ->
					parcialAvailableDay = availableDay.startDateUtc.split('T')[0]
					parcialSelectedDay = selectedDay.split('T')[0]
					return parcialAvailableDay == parcialSelectedDay

				timetable = _.filter @cartData.availableDeliveryWindows, (dw) =>
					parcialDWDate = dw.startDateUtc.split('T')[0]
					parcialDay = @cartData.selectedDay.startDateUtc.split('T')[0]
					return parcialDay == parcialDWDate

				@cartData.selectedTimetable = _.find timetable, (tt) =>
					return @cartData.selectedSla.deliveryWindow.startDateUtc == tt.startDateUtc

				@cartData.selectedDeliveryWindow =
					timetable: timetable

				@cartData.selectedTimetable.isSelected = true
				@cartData.selectedDay.isSelected = true

				_.each @.cartData.availableDeliveryWindows, (dw) =>
					dw.totalPrice = dw.price + @cartData.scheduledDeliverySla.price
					dw.totalPriceInCurrency = _.intAsCurrency dw.totalPrice

			else
				@cartData.isScheduledSla = false

	prepareDeliveryOptionsSelectors: =>
		self = this

		availableDeliveryOptions = $('.available-delivery-options')
		availableDates = $('.available-dates')
		availableTimetables = $('.available-timetables')

		availableDeliveryOptions.on 'change', ->
			self.cartData.selectedSla.isSelected = false
			selectedSlaPosition = $(this).val()
			selectedSla = self.cartData.slas[selectedSlaPosition]
			selectedSla.isSelected = true
			self.cartData.selectedSla = selectedSla
			self.cartData.isScheduledSla = selectedSla.availableDeliveryWindows.length > 0 ? true : false
			self.prepareCart()
			self.render()

		availableDates.on 'change', ->
			self.cartData.selectedDay?.isSelected = false
			selectedDayPosition = $(this).val()
			selectedDay = self.cartData.availableDays[selectedDayPosition]
			selectedDay.isSelected = true
			self.cartData.selectedDay = selectedDay

			self.cartData.selectedDay = _.find self.cartData.availableDays, (availableDay) ->
				parcialAvailableDay = availableDay.startDateUtc.split('T')[0]
				parcialSelectedDay = selectedDay.startDateUtc.split('T')[0]
				return parcialAvailableDay == parcialSelectedDay

			self.cartData.timetableForSelectedDay = _.filter self.cartData.availableDeliveryWindows, (dw) =>
				parcialDWDate = dw.startDateUtc.split('T')[0]
				parcialDay = self.cartData.selectedDay.startDateUtc.split('T')[0]
				return parcialDay == parcialDWDate

			self.cartData.selectedTimetable = _.find self.cartData.timetableForSelectedDay, (tt) =>
				return self.cartData.selectedDay.startDateUtc == tt.startDateUtc

			self.cartData.selectedDeliveryWindow =
				timetable: self.cartData.timetableForSelectedDay

			self.render()

		availableDeliveryOptions.on 'change', ->
			selectedSlaPosition = $(this).val()
			selectedSla = self.cartData.slas[selectedSlaPosition]

			if selectedSla.availableDeliveryWindows.length == 0
				self.sendShippingDataAttachment()

		availableDates.on 'change', ->
			self.sendShippingDataAttachment()

		availableTimetables.on 'change', ->
			self.sendShippingDataAttachment()

	sendShippingDataAttachment: =>

		selectedDeliveryOption = $('.available-delivery-options').val()
		selectedDeliveryWindow = $('.available-timetables').val() or $('.available-timetable').data('value')

		selectedSla = @cartData.slas[selectedDeliveryOption]

		attachment =
			address: _.clone @cartData.shippingData.address
			logisticsInfo: _.map @cartData.items, (item, index) ->
				itemIndex: index
				selectedSla: selectedSla.id

		if selectedSla.availableDeliveryWindows.length > 0

			deliveryWindow = _.find @cartData.availableDeliveryWindows, (dw) ->
				return dw.startDateUtc == selectedDeliveryWindow

			_.each attachment.logisticsInfo, (li) ->
				li.deliveryWindow = deliveryWindow

		@cartData.isLoading = true
		vtexjs.checkout.sendAttachment('shippingData', attachment)
		@render()

	prepareCart: =>
		# Conditionals
		@cartData.selectedTimetable = null
		@cartData.selectedDeliveryWindow = null
		@cartData.isLoading = false
		@cartData.showMinicart = @options.showMinicart
		@cartData.showTotalizers = @options.showTotalizers
		@cartData.showShippingOptions = @options.showShippingOptions

		# Amount Items
		@cartData.amountItems = 0
		if @cartData.items
			@cartData.amountItems += item.quantity for item in @cartData.items

		# Total
		total = 0
		if @cartData.totalizers
			for subtotal in @cartData.totalizers
				total += subtotal.value if subtotal.id in ['Items', 'Discounts']
		@cartData.totalCart = _.intAsCurrency(total, @options)

		# Item labels
		if @cartData.items
			for item in @cartData.items
				item.availabilityMessage = @getAvailabilityMessage(item)
				item.formattedPrice = _.intAsCurrency(item.sellingPrice, @options) + if item.measurementUnit and item.measurementUnit != 'un' then " (por cada #{item.unitMultiplier} #{item.measurementUnit})" else ''

		# Shipping Options
    if @cartData.showShippingOptions
      if @cartData.shippingData?.logisticsInfo?.length > 0
        @cartData.slas = @cartData.shippingData.logisticsInfo[0].slas

        @cartData.scheduledDeliverySla = _.find @cartData.slas, (sla) ->
          return sla.availableDeliveryWindows.length > 0

        _.each @cartData.slas, (sla) ->
          sla.priceInCurrency = _.intAsCurrency sla.price
          estimateDelivery = parseInt sla.shippingEstimate.match(/\d+/)[0]

          if sla.availableDeliveryWindows.length > 0
            sla.estimateDeliveryLabel = formatDate sla.availableDeliveryWindows[0].startDateUtc
          else
            sla.estimateDeliveryLabel = "Até #{estimateDelivery} dia"
            sla.estimateDeliveryLabel += "s" if estimateDelivery > 1

          if sla.availableDeliveryWindows.length > 0
            sla.label = "#{sla.name}"
          else
            sla.label = "#{sla.name} - #{sla.priceInCurrency} - #{sla.estimateDeliveryLabel}"

        if @cartData.scheduledDeliverySla?
          @cartData.availableDeliveryWindows = @cartData.selectedSla?.availableDeliveryWindows or @cartData.scheduledDeliverySla.availableDeliveryWindows

          _.each @.cartData.availableDeliveryWindows, (dw) =>
            dw.totalPrice = dw.price + @cartData.scheduledDeliverySla.price
            dw.totalPriceInCurrency = _.intAsCurrency dw.totalPrice

          @cartData.availableDays = _.uniq @cartData.availableDeliveryWindows, (dw) ->
            return dw.startDateUtc.split('T')[0]

	render: =>
		data = $.extend({options: @options}, @cartData)
		if @cartData.shippingData?.logisticsInfo?.length is 0 or
				@cartData.shippingData?.logisticsInfo?[0].slas?.length is 0
			data.showShippingOptions = false
		dust.render 'minicart', data, (err, out) =>
			throw new Error "Minicart Dust error: #{err}" if err
			@element.html out
			self = this
			@prepareDeliveryOptionsSelectors()
			$(".vtexsc-productList .cartSkuRemove", @element).on 'click', ->
				self.deleteItem(this) # Keep reference to event handler

	slide: =>
		if @cartData.items.length is 0
			@element.find(".vtexsc-cart").slideUp()
		else
			@element.find(".vtexsc-cart").slideDown()
			@timeoutToHide = setTimeout =>
				@element.find(".vtexsc-cart").stop(true, true).slideUp()
			, 3000

	deleteItem: (item) =>
		$(item).parent().find('.vtexsc-overlay').show()

		removedItem =
			index: $(item).data("index")
			quantity: 0

		vtexjs.checkout.removeItems([removedItem])
			.done (data) =>
				@element.trigger 'vtex.minicart.updated' #DEPRECATED
				@element.trigger 'minicartUpdated.vtex'
				@element.trigger 'vtex.cart.productRemoved' #DEPRECATED
				@element.trigger 'cartProductRemoved.vtex'
				@cartData = data
				@prepareCart()
				@render()
				@slide()

	getAvailabilityCode: (item) =>
		item.availability or "available"

	getAvailabilityMessage: (item) =>
		@options.availabilityMessages[@getAvailabilityCode(item)]


# PLUGIN ENTRY POINT
$.fn.minicart = (jsOptions) ->
	defaultOptions = $.extend true, {}, $.fn.minicart.defaults
	for element in this
		$element = $(element)
		domOptions = $element.data()
		options = $.extend(true, defaultOptions, domOptions, jsOptions)
		unless $element.data('minicart')
			$element.data('minicart', new Minicart($element, options))

	return this

# PLUGIN DEFAULTS
$.fn.minicart.defaults =
	availabilityMessages:
		"available": ""
		"unavailableItemFulfillment": "Este item não está disponível no momento."
		"withoutStock": "Este item não está disponível no momento."
		"cannotBeDelivered": "Este item não está disponível no momento."
		"withoutPrice": "Este item não está disponível no momento."
		"withoutPriceRnB": "Este item não está disponível no momento."
		"nullPrice": "Este item não está disponível no momento."
	showMinicart: true
	showTotalizers: true
	orderFormURL: "/api/checkout/pub/orderForm/"
	checkoutHash: '/orderform'
