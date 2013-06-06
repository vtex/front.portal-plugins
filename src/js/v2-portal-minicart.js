// o ponto-e-vírgula antes de invocar a função é uma prática segura contra scripts
// concatenados e/ou outros plugins que não foram fechados corretamente.
;(function ( $, window, document, undefined ) {

    // 'undefined' é usado aqui como a variável global 'undefined', no ECMAScript 3 é
    // mutável (ou seja, pode ser alterada por alguém). 'undefined' não está sendo
    // passado na verdade, assim podemos assegurar que o valor é realmente indefinido.
    // No ES5, 'undefined' não pode mais ser modificado.

    // 'window' e 'document' são passados como variáveis locais ao invés de globais,
    // assim aceleramos (ligeiramente) o processo de resolução e pode ser mais eficiente
    // quando minificado (especialmente quando ambos estão referenciados corretamente).

    // Cria as propriedades padrão
    var pluginName = "vtexCartItems",
        defaults = {
            orderFormId: 0,
            timeoutToHide:0
        };

    // O verdadeiro construtor do plugin
    function vtexCartItems( element, options ) {
        this.element = element;

        // jQuery tem um método 'extend' que mescla o conteúdo de dois ou
        // mais objetos, armazenando o resultado no primeiro objeto. O primeiro
        // objeto geralmente é vazio já que não queremos alterar os valores
        // padrão para futuras instâncias do plugin
        this.options = $.extend( {}, defaults, options );

        this._defaults = defaults;
        this._name = pluginName;

        this.init();
    }

    vtexCartItems.prototype = {

        init: function() {
            // Coloque a lógica de inicialização aqui
            // Você já possui acesso ao elemento do DOM e as opções da instância
            // exemplo: this.element e this.options

            this.getData(true);


        },

        getData: function(items) {
            self = this;

            // vtexMinicartGetData
            var promise = $.ajax({
                url: '/api/checkout/pub/orderForm/',
                data: JSON.stringify({"expectedOrderFormSections":["items", "paymentData", "totalizers"]}),
                dataType: 'json',
                contentType: 'application/json; charset=utf-8',
                type: 'POST'
            });

            promise.done(function(data) {
                self.options.orderFormId = data.orderFormId;

                if (items) self.insertCartItems(data);
                self.changeCartValues(data);
                if (!items) self.updateItems(data);
            });
            promise.fail(function(jqXHR, textStatus, errorThrown) {
                console.log('Error Message: '+textStatus);
                console.log('HTTP Error: '+errorThrown);
            });
            return promise;
        },
        insertCartItems: function(data) {
            self = this;

            // vtexMinicartInsertCartItems
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
                                        <span class="vtexsc-text">R$ ' + self.formatCurrency(total) + '</span>\
                                    </span>\
                                </div>\
                                <a href="/checkout/#/orderform" class="cartCheckout"></a>\
                            </div>\
                        </div>\
                        <div class="vtexsc-bb"></div>\
                    </div>';

                $(self.element).prepend(miniCart);

                self.updateItems(data);

                $('.carrinhoCompras, .linkCart, .vtexsc-cart').mouseenter(function() {
                    $('.vtexsc-cart').slideDown();
                    clearTimeout(self.options.timeoutToHide);
                }).mouseleave(function() {
                    clearTimeout(self.options.timeoutToHide);
                    self.options.timeoutToHide = setTimeout(function() {
                        $('.vtexsc-cart').slideUp();
                    }, 800);
                });
            }
        },
        updateItems: function(data) {
            self = this;

            //vtexMinicartUpdateItems
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
                                <span class="bestPrice">' + self.formatCurrency(c.price) + '</span>\
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
                    var elem = $(this);
                    var promise = $.ajax({
                        url: '/api/checkout/pub/orderForm/'+ self.options.orderFormId +'/items/update/',
                        data: JSON.stringify({"expectedOrderFormSections":["items", "paymentData", "totalizers"], "orderItems": [{"index": elem.data('index'), "quantity": 0}]}),
                        dataType: 'json',
                        contentType: 'application/json; charset=utf-8',
                        type: 'POST'
                    });
                    promise.done(function(data) {
                        self.changeCartValues(data);
                        self.updateItems(data);
                    });
                    promise.fail(function(jqXHR, textStatus, errorThrown) {
                        console.log('Error Message: '+textStatus);
                        console.log('HTTP Error: '+errorThrown);
                    });
                });
            }
        },
        changeCartValues: function(data) {
            //vtexMinicartChangeCartValues
            if (data) {
                var items = data.items;
                var total = 0;

                $.each(data.totalizers, function(i, t) {
                    total += t.value;
                });

                $('.vtexsc-totalCart .vtexsc-text').text(this.formatCurrency(total));
                $('.carrinhoCompras > a, .linkCart').attr('href', '/checkout/#/cart');
            }
        },
        formatCurrency: function(value) { 
            //vtexMinicartFormatCurrency
            num = isNaN(value) || value === '' || value === null ? 0.00 : value / 100; return parseFloat(num).toFixed(2).replace('.',',').toString().replace(/(\d)(?=(\d\d\d)+(?!\d))/g, '$1.');
        },
        showMinicart: function(value) { 
            //vtexMinicartShowMinicart
            var promise = this.getData();
            promise.done(function() {
                $('.vtexsc-cart').slideDown();
                clearTimeout(this.options.timeoutToHide);
                this.options.timeoutToHide = setTimeout(function() {
                    $('.vtexsc-cart').slideUp();
                }, 3000);
            });
        }

    };

    // Um invólucro realmente leve em torno do construtor,
    // prevenindo contra criação de múltiplas instâncias
    $.fn[pluginName] = function ( options ) {
        return this.each(function () {
            if (!$.data(this, "plugin_" + pluginName)) {
                $.data(this, "plugin_" + pluginName, new vtexCartItems( this, options ));
            }
        });
    };

})( jQuery, window, document );
$('.header').vtexCartItems();

$('body')on("cartItems", function(event){
  alert($(this).text());
});