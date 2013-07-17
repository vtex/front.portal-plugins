(($, window, document) ->

  pluginName = 'vtexMinicart'
  defaults = {
    timeoutToHide: null
    cartData: null
    $template: null
  }

  class vtexMinicart
    constructor: (@element, options) ->
      @options = $.extend {}, defaults, options

      @_defaults = defaults
      @_name = pluginName

      @init()

    init: ->
      self = this

      self.options.$template = $ """
      <div class="v2-vtexsc-cart vtexsc-cart mouseActivated preLoaded" style="display: none;">
        <div class="vtexsc-bt"></div>
        <div class="vtexsc-center">
            <div class="vtexsc-wrap">
                <table class="vtexsc-productList">
                    <thead style="display: none;">
                        <tr>
                            <th class="cartSkuName" colspan="2">Produto</th>
                            <th class="cartSkuPrice">Preço</th>
                            <th class="cartSkuQuantity">Quantidade</th>
                            <th class="cartSkuActions">Excluir</th>
                        </tr>
                    </thead>
                    <tbody></tbody>
                </table>
            </div>
            <div class="cartFooter clearfix">
                <div class="cartTotal">
                    Total\
                    <span class="vtexsc-totalCart">
                        #{self.getCurrency()} <span class="vtexsc-text"> 0</span>
                    </span>
                </div>
                <a href="/checkout/#/orderform" class="cartCheckout"></a>
            </div>
        </div>
        <div class="vtexsc-bb"></div>
      </div>
      """

      $(self.element).after self.options.$template

      $(self.options.$template)
      .mouseover ->
        $(window).trigger "miniCartMouseOver"
      .mouseout ->
        $(window).trigger "miniCartMouseOut"

      $(window).on "miniCartMouseOver", ->
        if self.options.cartData?.items.length > 0
          $(".vtexsc-cart").slideDown()
          clearTimeout self.options.timeoutToHide

      $(window).on "miniCartMouseOut", ->
        clearTimeout self.options.timeoutToHide
        self.options.timeoutToHide = setTimeout ->
          $(".vtexsc-cart").stop(true, true).slideUp()
        , 800

      $(window).on "cartUpdated", (event, cartData, show) ->
        if cartData?.items? and cartData.items.length is 0
          $(".vtexsc-cart").slideUp()
          return
        if show
          $(".vtexsc-cart").slideDown()
          self.options.timeoutToHide = setTimeout ->
            $(".vtexsc-cart").stop(true, true).slideUp()
          , 3000

      $(window).on 'productAddedToCart', ->
        promiseAdd = self.getData()
        promiseAdd.success (data) ->
          self.updateItems data
          self.changeCartValues data
          $(window).trigger "cartUpdated", [null, true]

      promise = @getData()
      promise.success (data) ->
        self.insertCartItems data
        self.changeCartValues data


    getData: ->
      self = this

      promise = $.ajax {
        url: "/api/checkout/pub/orderForm/"
        data: JSON.stringify(expectedOrderFormSections: ["items", "paymentData", "totalizers"])
        dataType: "json"
        contentType: "application/json; charset=utf-8"
        type: "POST"
      }

      promise.done (data) ->
        self.options.cartData = data

      promise.fail (jqXHR, textStatus, errorThrown) ->
        # console.log "Error Message: " + textStatus
        # console.log "HTTP Error: " + errorThrown

      promise

    insertCartItems: (data) ->
      self = this

      if data
        total = 0

        for subtotal in data.totalizers
          total += subtotal.value if subtotal.id is 'Items'

        $('.vtexsc-text', self.options.$template).text self.formatCurrency(total)

        self.updateItems data

    deleteItem: (item) ->
      self = this

      $(item).parent().find('.vtexsc-overlay').show()

      data = JSON.stringify(
        expectedOrderFormSections: ["items", "paymentData", "totalizers"]
        orderItems: [
          index: $(item).data("index")
          quantity: 0
        ]
      )

      promise = $.ajax {
        url: "/api/checkout/pub/orderForm/" + self.options.cartData.orderFormId + "/items/update/"
        data: data
        dataType: "json"
        contentType: "application/json; charset=utf-8"
        type: "POST"
      }

      promise.success (data) ->
        self.options.cartData = data
        self.changeCartValues data
        self.updateItems data
        $(window).trigger "cartUpdated", [data]

      promise.done ->
        $(item).parent().find('.vtexsc-overlay').hide()

      promise.fail (jqXHR, textStatus, errorThrown) ->
        # console.log "Error Message: " + textStatus
        # console.log "HTTP Error: " + errorThrown

    updateItems: (data) ->
      self = this
      $template = self.options.$template

      if data
        items = ''

        $(".vtexsc-productList tbody", $template).html ""

        for item, i in data.items
          item = """
          <tr>
              <td class="cartSkuImage">
                  <a class="sku-imagem" href="#{item.detailUrl}"><img height="71" width="71" alt="#{item.name}" src="#{item.imageUrl}" /></a>
              </td>
              <td class="cartSkuName">
                  <h4><a href="#{item.detailUrl}">"#{item.name}"</a><br /></h4>
              </td>
              <td class="cartSkuPrice">
                  <div class="cartSkuUnitPrice">
                      #{self.getCurrency()} <span class="bestPrice">#{self.formatCurrency(item.price)}</span>
                  </div>
              </td>
              <td class="cartSkuQuantity">
                  <div class="cartSkuQtt">
                      <span class="cartSkuQttTxt"><span class="vtexsc-skuQtt">#{item.quantity}</span></span>
                  </div>
              </td>
              <td class="cartSkuActions">
                  <span class="cartSkuRemove" data-index="#{i}">
                      <a href="javascript:void(0);" class="text" style="display: none;">excluir</a>
                  </span>
                  <div class="vtexsc-overlay" style="display: none;"></div>
              </td>
          </tr>
          """
          items += item

        $(".vtexsc-productList tbody", $template).html items

        $(".vtexsc-productList .cartSkuRemove", $template).click ->
          self.deleteItem(this)

    changeCartValues: (data) ->
      self = this;

      if data
        total = 0
        for subtotal in data.totalizers
          total += subtotal.value if subtotal.id is 'Items'

        $(".vtexsc-text", self.options.$template).text(self.formatCurrency (total))

    formatCurrency: (value) ->
      if value is '' or not value? or isNaN value
        num = 0.00
      else
        num = value / 100
      parseFloat(num).toFixed(2).replace('.', ',').toString().replace(/(\d)(?=(\d\d\d)+(?!\d))/g, '$1.')

    showMinicart: (value) ->
      promise = @getData()
      promise.done ->
        self.updateItems data
        $(".vtexsc-cart").slideDown()
        clearTimeout @options.timeoutToHide
        @options.timeoutToHide = setTimeout ->
          $(".vtexsc-cart").slideUp()
        , 3000

    getCurrency: ->
      vtex?.i18n?.getCurrency() or "R$"

    $.fn[pluginName] = (options) ->
      @each ->
        if !$.data(this, "plugin_#{pluginName}")
          $.data(@, "plugin_#{pluginName}", new vtexMinicart(@, options))

)( jQuery, window, document )

$ -> $('.portal-minicart-ref').vtexMinicart()
# $ -> $('#vtex-minicart').vtexMinicart()