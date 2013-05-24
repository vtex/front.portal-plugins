var vtexMinicartShowMinicart;
var vtexMinicartOrderFormId;

$(window).load(function() {
    var vtexMinicartTimeoutToHide;

    var vtexMinicartGetData = function(items) {
        var promise = $.ajax({
            url: '/api/checkout/pub/orderForm/',
            data: JSON.stringify({"expectedOrderFormSections":["items", "paymentData", "totalizers"]}),
            dataType: 'json',
            contentType: 'application/json; charset=utf-8',
            type: 'POST'
        });
        promise.done(function(data) {
            vtexMinicartOrderFormId = data.orderFormId;

            if (items) vtexMinicartInsertCartItems(data);
            vtexMinicartChangeCartValues(data);
            if (!items) vtexMinicartUpdateItems(data);
        });
        promise.fail(function(jqXHR, textStatus, errorThrown) {
            console.log('Error Message: '+textStatus);
            console.log('HTTP Error: '+errorThrown);
        });
        return promise;
    }

    var vtexMinicartFormatCurrency = function(value) { num = isNaN(value) || value === '' || value === null ? 0.00 : value / 100; return parseFloat(num).toFixed(2).replace('.',',').toString().replace(/(\d)(?=(\d\d\d)+(?!\d))/g, '$1.');}
    var vtexMinicartChangeCartValues = function(data) {
        if (data) {
            var items = data.items;
            var total = 0;

            $.each(data.totalizers, function(i, t) {
                total += t.value;
            });

            $('.amount-items-em').text('Itens: ' + items.length);
            $('.total-cart-em').text(vtexMinicartFormatCurrency(total));
            $('.vtexsc-totalCart .vtexsc-text').text(vtexMinicartFormatCurrency(total));
            $('.carrinhoCompras > a, .linkCart').attr('href', '/checkout/#/cart');
        }
    }
    var vtexMinicartInsertCartItems = function(data) {
        if (data) {
            var items = data.items;
            var total = 0;

            $.each(data.totalizers, function(i, t) {
                total += t.value;
            });

            var miniCart = '<div class="v2-vtexsc-cart vtexsc-cart mouseActivated preLoaded">\
                <div class="vtexsc-bt"></div>\
                    <div class="vtexsc-center">\
                        <div class="vtexsc-wrap">\
                            <table class="vtexsc-productList">\
                                <tbody></tbody>\
                            </table>\
                        </div>\
                        <div class="cartFooter clearfix">\
                            <div class="cartTotal">\
                                Total\
                                <span class="vtexsc-totalCart">\
                                    <span class="vtexsc-text">R$ ' + vtexMinicartFormatCurrency(total) + '</span>\
                                </span>\
                            </div>\
                            <a href="/checkout/#/orderform" class="cartCheckout"></a>\
                        </div>\
                    </div>\
                    <div class="vtexsc-bb"></div>\
                </div>';
            
            $('.header:not(.floatingTopBar)').prepend(miniCart);

            vtexMinicartUpdateItems(data);

            $('.carrinhoCompras, .linkCart, .vtexsc-cart').mouseenter(function() {
                $('.vtexsc-cart').slideDown();
                clearTimeout(vtexMinicartTimeoutToHide);
            }).mouseleave(function() {
                clearTimeout(vtexMinicartTimeoutToHide);
                vtexMinicartTimeoutToHide = setTimeout(function() {
                    $('.vtexsc-cart').slideUp();
                }, 800);
            });
        }
    }

    vtexMinicartUpdateItems = function(data) {
        if (data) {
            var items = data.items;
            var total = 0;

            $.each(data.totalizers, function(i, t) {
                total += t.value;
            });

            $('.vtexsc-productList tbody').html('');

            $.each(items, function(i, c) {
                var item = '<tr>\
                    <td class="cartSkuImage">\
                        <a class="sku-imagem" href="' + c.detailUrl + '"><img height="71" width="71" alt="' + c.name + '" src="' + c.imageUrl + '" /></a>\
                    </td>\
                    <td class="cartSkuName">\
                        <h4><a href="' + c.detailUrl + '">' + c.name + '</a><br /></h4>\
                    </td>\
                    <td class="cartSkuPrice">\
                        <div class="cartSkuUnitPrice">\
                            <span class="bestPrice">' + vtexMinicartFormatCurrency(c.price) + '</span>\
                        </div>\
                    </td>\
                    <td class="cartSkuQuantity">\
                        <div class="cartSkuQtt">\
                            <span class="cartSkuQttTxt"><span class="vtexsc-skuQtt">' + c.quantity + '</span></span>\
                        </div>\
                    </td>\
                    <td class="cartSkuActions">\
                        <span class="cartSkuRemove" data-index="'+ i +'"></span>\
                    </td>\
                </tr>';

                $('.vtexsc-productList tbody').append(item);

            });

            $('.vtexsc-productList .cartSkuRemove').click(function() {
                var self = $(this);
                var promise = $.ajax({
                    url: '/api/checkout/pub/orderForm/'+ vtexMinicartOrderFormId +'/items/update/',
                    data: JSON.stringify({"expectedOrderFormSections":["items", "paymentData", "totalizers"], "orderItems": [{"index": self.data('index'), "quantity": 0}]}),
                    dataType: 'json',
                    contentType: 'application/json; charset=utf-8',
                    type: 'POST'
                });
                promise.done(function(data) {
                    vtexMinicartChangeCartValues(data);
                    vtexMinicartUpdateItems(data);
                });
                promise.fail(function(jqXHR, textStatus, errorThrown) {
                    console.log('Error Message: '+textStatus);
                    console.log('HTTP Error: '+errorThrown);
                });
            });
        }
    }

    vtexMinicartShowMinicart = function() {
        var promise = vtexMinicartGetData();
        promise.done(function() {
            $('.vtexsc-cart').slideDown();
            clearTimeout(vtexMinicartTimeoutToHide);
            vtexMinicartTimeoutToHide = setTimeout(function() {
                $('.vtexsc-cart').slideUp();
            }, 3000);
        });
    }

    if ($('meta[name=vtex-version]').length > 0) {
        vtexMinicartGetData(true);
    }
});
