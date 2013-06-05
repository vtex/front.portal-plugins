var formatCurrency = function(value) { num = isNaN(value) || value === '' || value === null ? 0.00 : value / 100; return parseFloat(num).toFixed(2).replace('.',',').toString().replace(/(\d)(?=(\d\d\d)+(?!\d))/g, '$1.');}

var getCartData = function(items) {
  var promise = $.ajax({
    url: '/api/checkout/pub/orderForm/',
    data: JSON.stringify({"expectedOrderFormSections":["items", "paymentData", "totalizers"]}),
    dataType: 'json',
    contentType: 'application/json; charset=utf-8',
    type: 'POST'
  });
  promise.done(function(data) {
    var quantity = 0;

    for (var i = 0; i < data.items.length; i++) {
      quantity += data.items[i].quantity;
    }

    $('.amount-items-in-cart').html('\
      <div class="ajax-content-loader">\
        <div class="cartInfoWrapper">\
          <span class="title"><span id="MostraTextoXml1">Resumo do Carrinho</span></span>\
          <ul class="cart-info">\
            <li class="amount-products">\
              <strong><span id="MostraTextoXml2">Total de Produtos:</span></strong><em class="amount-products-em">'+data.items.length+'</em>\
            </li>\
            <li class="amount-items">\
              <strong><span id="MostraTextoXml3">Itens:</span></strong><em class="amount-items-em">'+quantity+'</em>\
            </li>\
            <li class="amount-kits">\
              <strong><span id="MostraTextoXml4">Total de Kits:</span></strong><em class="amount-kits-em">0</em>\
            </li>\
            <li class="total-cart">\
              <strong><span id="MostraTextoXml5">Valor Total:</span></strong><em class="total-cart-em">R$ '+formatCurrency(data.value)+'</em>\
            </li>\
          </ul>\
        </div>\
      </div>\
    ');
  });
  promise.fail(function(jqXHR, textStatus, errorThrown) {
      console.log('Error Message: '+textStatus);
      console.log('HTTP Error: '+errorThrown);
  });
}

