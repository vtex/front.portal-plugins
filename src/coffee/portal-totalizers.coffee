qq(($, window, document) ->

  pluginName = 'vtexTotalizers'
  defaults = {
    $template: null
  }

  class vtexTotalizers
    constructor: (@element, options) ->
      @options = $.extend {}, defaults, options

      @_defaults = defaults
      @_name = pluginName

      @init()

    init: ->
      self = this

      self.options.$template = $ """
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
              <strong><span id="MostraTextoXml5">Valor Total:</span></strong> <em class="total-cart-em"></em>
            </li>
          </ul>
        </div>
      </div>
      """

      $(self.element).after self.options.$template

      self.selectors = {
        amountProducts: $('.amount-products-em', self.options.$template)
        amountItems: $('.amount-items-em', self.options.$template)
        totalCart: $('.total-cart-em', self.options.$template)
      }

      self.getCartData()

      $(window).on 'cartUpdated', (event, cartData) ->
        if (cartData)
          self.setCartData(cartData)
        else
          self.getCartData()

      $('.amount-items-in-cart, .show-minicart-on-hover').mouseover ->
        $(window).trigger 'miniCartMouseOver'

      $('.amount-items-in-cart, .show-minicart-on-hover').mouseout ->
        $(window).trigger 'miniCartMouseOut'

    formatCurrency: (value) ->
      if value is '' or not value? or isNaN value
        num = 0.00
      else
        num = value / 100
      @getCurrency() + ' ' + parseFloat(num).toFixed(2).replace('.', ',').toString().replace(/(\d)(?=(\d\d\d)+(?!\d))/g, '$1.')

    getCartData: ->
      self = this

      $(self.options.$template).addClass 'amount-items-in-cart-loading'

      promise = $.ajax {
        url: '/api/checkout/pub/orderForm/'
        data: JSON.stringify {"expectedOrderFormSections": ["items", "paymentData", "totalizers"]}
        dataType: 'json'
        contentType: 'application/json; charset=utf-8'
        type: 'POST'
      }

      promise.done (data) ->
        $(self.options.$template).removeClass 'amount-items-in-cart-loading'

      promise.success (data) ->
        self.setCartData data

      promise.fail (jqXHR, textStatus, errorThrown) ->
        # console.log 'Error Message: ' + textStatus;
        # console.log 'HTTP Error: ' + errorThrown;

      promise

    setCartData: (data) ->
      self = this

      amountProducts = data.items.length
      amountItems = 0;
      amountItems += item.quantity for item in data.items

      total = 0
      for subtotal in data.totalizers
        total += subtotal.value if subtotal.id is 'Items'
      totalCart = self.formatCurrency(total)

      self.selectors.amountProducts.html amountProducts
      self.selectors.amountItems.html amountItems
      self.selectors.totalCart.html totalCart

    getCurrency: ->
      vtex?.i18n?.getCurrency() or "R$"

    $.fn[pluginName] = (options) ->
      @each ->
        if !$.data(this, "plugin_#{pluginName}")
          $.data(@, "plugin_#{pluginName}", new vtexTotalizers(@, options))

)( jQuery, window, document )

$ -> $('.portal-totalizers-ref').vtexTotalizers()
# $ -> $('.carrinhoCompras a').vtexTotalizers()
