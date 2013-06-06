(($, window, document) ->

  pluginName = "vtexTotalizers"
  defaults = {}

  class vtexTotalizers
    constructor: (@element, options) ->
      @options = $.extend {}, defaults, options

      @_defaults = defaults
      @_name = pluginName

      @init()

    init: ->
      self = this

      template = """
      <div class="amount-items-in-cart amount-items-in-cart-loading">
        <div class="ajax-content-loader">
          <div class="cartInfoWrapper">
            <span class="title"><span id="MostraTextoXml1">Resumo do Carrinho</span></span>
            <ul class="cart-info">
              <li class="amount-products">
                <strong><span id="MostraTextoXml2">Total de Produtos:</span></strong> <em class="amount-products-em"></em>
              </li>
              <li class="amount-items">
                <strong><span id="MostraTextoXml3">Itens:</span></strong> <em class="amount-items-em"></em>
              </li>
              <li class="amount-kits">
                <strong><span id="MostraTextoXml4">Total de Kits:</span></strong> <em class="amount-kits-em">0</em>
              </li>
              <li class="total-cart">
                <strong><span id="MostraTextoXml5">Valor Total:</span></strong> R$ <em class="total-cart-em"></em>
              </li>
            </ul>
          </div>
        </div>
      </div>
      """
      $(self.element).html template

      self.selectors = {
        amountProducts: $('.amount-products-em')
        amountItems: $('.amount-items-em')
        totalCart: $('.total-cart-em')
      }

      self.getCartData()

      $('body').on 'cartUpdate', ->
        self.getCartData()

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

      promise.success (data) ->
        amountProducts = data.items.length
        amountItems = 0;
        amountItems += item.quantity for item in data.items
        totalCart = self.formatCurrency data.value

        self.selectors.amountProducts.html amountProducts
        self.selectors.amountItems.html amountItems
        self.selectors.totalCart.html totalCart

      promise.fail (jqXHR, textStatus, errorThrown) ->
        console.log 'Error Message: ' + textStatus;
        console.log 'HTTP Error: ' + errorThrown;

  # A really lightweight plugin wrapper around the constructor,
  # preventing against multiple instantiations
  $.fn[pluginName] = (options) ->
    @each ->
      if !$.data(this, "plugin_#{pluginName}")
        $.data(@, "plugin_#{pluginName}", new vtexTotalizers(@, options))

)( jQuery, window, document )

$('.amount-items-in-cart-wrapper').vtexTotalizers()