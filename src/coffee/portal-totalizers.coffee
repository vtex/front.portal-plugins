(($, window, document) ->

  pluginName = 'vtexTotalizers'
  defaults = {}

  class vtexTotalizers
    constructor: (@element, options) ->
      @options = $.extend {}, defaults, options

      @_defaults = defaults
      @_name = pluginName

      @init()

    init: ->
      self = this

      template = $ """
      <div class="amount-items-in-cart amount-items-in-cart-loading">
        <div class="cartInfoWrapper">
          <span class="title"><span id="MostraTextoXml1">Resumo do Carrinho</span></span>
          <ul class="cart-info">
            <li class="amount-products">
              <strong><span id="MostraTextoXml2">Total de Produtos:</span></strong> <em class="amount-products-em">0</em>
            </li>
            <li class="amount-items">
              <strong><span id="MostraTextoXml3">Itens:</span></strong> <em class="amount-items-em">0</em>
            </li>
            <li class="amount-kits">
              <strong><span id="MostraTextoXml4">Total de Kits:</span></strong> <em class="amount-kits-em">0</em>
            </li>
            <li class="total-cart">
              <strong><span id="MostraTextoXml5">Valor Total:</span></strong> R$ <em class="total-cart-em">0,00</em>
            </li>
          </ul>
        </div>
      </div>
      """

      self.selectors = {
        amountProducts: $('.amount-products-em', template)
        amountItems: $('.amount-items-em', template)
        totalCart: $('.total-cart-em', template)
      }

      $(self.element)
        .removeAttr('id')
        .after template

      self.getCartData()

      $(window).on 'cartUpdated', ->
        self.getCartData()
        return

      $('.amount-items-in-cart, .show-minicart-on-hover').mouseover ->
        $(window).trigger 'miniCartMouseOver'
        return

      $('.amount-items-in-cart, .show-minicart-on-hover').mouseout ->
        $(window).trigger 'miniCartMouseOut'
        return

      return

    formatCurrency: (value) ->
      if value is '' or not value? or isNaN value
        num = 0.00
      else
        num = value / 100
      parseFloat(num).toFixed(2).replace('.', ',').toString().replace(/(\d)(?=(\d\d\d)+(?!\d))/g, '$1.')

    getCartData: (items) ->
      self = this

      $('.amount-items-in-cart').addClass 'amount-items-in-cart-loading'

      promise = $.ajax {
        url: '/api/checkout/pub/orderForm/'
        data: JSON.stringify {"expectedOrderFormSections": ["items", "paymentData", "totalizers"]}
        dataType: 'json'
        contentType: 'application/json; charset=utf-8'
        type: 'POST'
      }

      promise.done (data) ->
        $('.amount-items-in-cart').removeClass 'amount-items-in-cart-loading'
        return

      # data = totalizersJson
      promise.success (data) ->
        amountProducts = data.items.length
        amountItems = 0;
        amountItems += item.quantity for item in data.items
        totalCart = self.formatCurrency data.value

        self.selectors.amountProducts.html amountProducts
        self.selectors.amountItems.html amountItems
        self.selectors.totalCart.html totalCart
        return

      promise.fail (jqXHR, textStatus, errorThrown) ->
        console.log 'Error Message: ' + textStatus;
        console.log 'HTTP Error: ' + errorThrown;
        return

      return

    $.fn[pluginName] = (options) ->
      @each ->
        if !$.data(this, "plugin_#{pluginName}")
          $.data(@, "plugin_#{pluginName}", new vtexTotalizers(@, options))
        return
      return

  return

)( jQuery, window, document )

$ -> $('script#vtex-totalizers').vtexTotalizers()