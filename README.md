### Índice

- Plugins
    - [Sku Selector](#sku-selector)
    - [Quantity Selector](#quantity-selector)
    - [Accessories Selector](#accessories-selector)
    - [Price](#price)
    - [ShippingCalculator](#shipping-calculator)
    - [Buy Button](#buy-button)
    - [Notify Me](#notify-me)
    - [Minicart](#minicart)

- [Notas](#notas)


---

# Sku Selector

## Uso

Chame o plugin em uma `div` vazia:

    $('.sku-selector-container').skuSelector(data, options);

- <b>`data`</b> deve ser um JSON de SKUs padrão da API.

- <b>`options`</b> opcional, é um objeto que pode ter as seguintes propriedades:
    - <b>`selectOnOpening`</b>
        default: `false`. Se `true`, na inicialização do plugin seleciona o primeiro SKU disponível (o primeiro que vier no array).

    - <b>`modalLayout`</b>
        default: `false`. Se `true`, usa o template de modal.

    - <b>`warnUnavailable`</b>
        default: `false`. Se `true`, mostra form de "avise-me" quando um SKU indisponível for selecionado.

    - <b>`showPriceRange`</b>
        default: `false`. Se `true`, mostra o preço mínimo e o máximo dentre os SKUs selecionáveis com as dimensões já selecionadas.

    - <b>`forceInputType`</b>
        default: `null`. Se não for falsy, força o inputType de todas as dimensões a serem isso.

## Eventos

Lança os seguintes eventos:

- <b>`vtex.sku.ready []`</b> quando o Sku Selector é renderizado.
- <b>`vtex.sku.dimensionChanged [productId, name, value]`</b> quando uma dimensão é selecionada.
- <b>`vtex.sku.selected [productId, sku]`</b> quando um SKU é definido.
- <b>`vtex.sku.unselected [productId, selectableSkus]`</b> quando o SKU torna-se indefinido.


---

# Quantity Selector

## Uso

Chame o plugin em uma `div` vazia:

    $('.quantity-selector-container').quantitySelector(productId, options);

- <b>`productId`</b> o ID do produto.

- <b>`options`</b> opcional, é um objeto que pode ter as seguintes propriedades

    - <b>`unitBased`</b>
        default: `false`. Define se deseja usar seletor a granel (calculadora de quantidade).

    - <b>`unitVariations`</b>
        default: `[]`. Se `unitBased == true`, especifica as opções de unidade para cada Sku. É uma coleção de `{skuId: Number, measurementUnit: String, unitMultiplier: Number}`.

    - <b>`max`</b>
        default: `10`. Define a quantidade máxima que pode ser selecionada.

    - <b>`initialQuantity`</b>
        default: `1`. Define a quantidade selecionada inicialmente.

    - <b>`decimalPlaces`</b>
        default: `2`. Define a quantidade de casas decimais do input de unidades. Não deve exceder 12.


## Eventos

Lança os seguintes eventos:

- <b>`vtex.quantity.ready [productId, quantity]`</b> quando o Quantity Selector é renderizado.
- <b>`vtex.quantity.changed [productId, quantity]`</b> quando a quantidade é mudada.

Escuta pelos seguintes eventos:

- <b>`vtex.quantity.changed [productId, quantity]`</b> a quantidade pode ser mudada por meio de scripts externos e o plugin se atualizará.


---

# Accessories Selector

## Uso

Chame o plugin em uma `div` vazia:

    $('.acc-selector-container').accessoriesSelector(productId, data, options);

- <b>`productId`</b> o ID do produto que é pai dos acessórios.

- <b>`data`</b> deve ser um JSON de acessórios padrão da API.

- <b>`options`</b> (nenhuma no momento.)

## Eventos

Lança os seguintes eventos:

- <b>`vtex.accessories.updated [productId, accessories]`</b> quando um acessório é alterado. O array `accessories` contém os acessórios de um determinado produto, com propriedades como `sku` e `quantity`.


---

# Price

Escuta por mudanças no Sku selecionado e atualiza as labels de preço.

Usa informações padrão de preço quando não há Sku selecionado.

## Uso

Chame o plugin em uma `div`. Se esta conter algum HTML, este será usado quando um Sku não estiver definido.

    $('.productPrice').price(productId, options);

- <b>`productId`</b> o ID do produto.

- <b>`options`</b> opcional, é um objeto que pode ter as seguintes propriedades

    - <b>`originalSku`</b>
        default: `null`. Deve ser definido se a opção acima for `true`.

    - <b>`modalLayout`</b>
        default: `false`. Se `true`, usa o template de modal.

## Eventos

Escuta pelos seguintes eventos:

- <b>`vtex.sku.selected [productId, sku]`</b>
- <b>`vtex.sku.unselected [productId, selectableSkus]`</b>


---

# Shipping Calculator

Oferece um formulário para cálculo de frete, além de um botão para mostrá-lo.

## Uso

Chame o plugin em uma `div` vazia.

    $('.shipping-calc-ref').shippingCalculator(productId, options);

- <b>`productId`</b> o ID do produto.

- <b>`options`</b> opcional, é um objeto que pode ter as seguintes propriedades

    - <b>`strings`</b>
        Define as mensagens exibidas. Default:

        {
            "calculateShipping": 'Calcule o valor do frete e prazo de entrega para a sua região:',
            "enterPostalCode": 'Calcular o valor do frete e verificar disponibilidade:',
            "requiredPostalCode": 'O CEP deve ser informado.',
            "invalidPostalCode": 'CEP inválido.',
            "requiredQuantity": 'É necessário informar a quantidade do mesmo Produto.',
            "siteName": 'Vtex.Commerce.Web.CommerceContext.Current.WebSite.Name',
            "close": 'Fechar'
        }

## Eventos

Escuta pelos seguintes eventos:

- <b>`vtex.sku.selected [productId, sku]`</b>
- <b>`vtex.sku.unselected [productId, selectableSkus]`</b>
- <b>`vtex.quantity.ready [productId, quantity]`</b>
- <b>`vtex.quantity.changed [productId, quantity]`</b>


---

# Buy Button

## Uso

Chame o plugin na `a` que age como botão de comprar:

    $('.buy-button').buyButton(productId, data, options);

- <b>`productId`</b> o ID do produto. Pode ser um array de IDs de produto -- neste caso, vai ser um botão que vai servir para comprar todos os produtos ao mesmo tempo.

- <b>`data`</b> opcional, é um objeto que pode ter as propriedades `sku`, `quantity`, `seller` e `salesChannel`.

- <b>`options`</b> opcional, é um objeto que pode ter as seguintes propriedades

    - <b>`errorMessage`</b>
        Mensagem de erro que será alertada se o usuário clicar no botão sem ter escolhido um SKU. Default: *"Por favor, selecione o modelo desejado."*

    - <b>`redirect`</b>
        default: `true`. Determina a propriedade de mesmo nome na querystring. <b>Deve ser `true` para página de produto, e `false` para modal.

    - <b>`instaBuy`</b>
        default: `false`. Se `true`, ao ser selecionado um Sku disponível, o botão se clica.

    - <b>`hideUnselected`</b>
        default: `false`. Se `true`, esconde-se quando não há Sku selecionado.

    - <b>`hideUnavailable`</b>
        default: `false`. Se `true`, esconde-se quando o Sku selecionado está indisponível.

    - <b>`target`</b>
        default: `null`. Define o query parameter `target`. Um valor válido é `"orderform"`.

    - <b>`requireAllSkus`</b>
        default: `false`. Se `productId` for um array, essa opção determina se todos os IDs de produto devem ter um Sku selecionado, ou se aceita comprar parcialmente (somente os selecionados).

## Eventos

Lança os seguintes eventos:

- <b>`vtex.modal.hide []`</b> quando `redirect=false` e o botão é clicado.
- <b>`vtex.cart.productAdded []`</b> quando `redirect=false`, o botão é clicado e a resposta do AJAX volta.

Escuta pelos seguintes eventos:

- <b>`vtex.sku.selected [productId, sku]`</b>
- <b>`vtex.sku.unselected [productId, selectableSkus]`</b>
- <b>`vtex.quantity.changed [productId, quantity]`</b>
- <b>`vtex.accessory.selected [productId, accessory]`</b>


---

# Notify Me

## Uso

Chame o plugin em uma `div` vazia:

    $('.portal-notify-me-ref').notifyMe(productId, options);

- <b>`productId`</b> o ID do produto.

- <b>`options`</b> opcional, é um objeto que pode ter as seguintes propriedades

    - <b>`ajax`</b>
        default: `true`. Define se o submit do form deve ser feito com AJAX.

    - <b>`sku`</b>
        default: `null`. Define o sku a ser usado. Se existir, ignora os eventos de seleção de sku.

    - <b>`strings`</b>
        Define as mensagens exibidas. Default:

            {
                "title": "",
                "explanation": "Para ser avisado da disponibilidade deste Produto, basta preencher os campos abaixo.",
                "namePlaceholder": "Digite seu nome...",
                "emailPlaceholder": "Digite seu e-mail...",
                "loading": "Carregando...",
                "success": "Cadastrado com sucesso. Assim que o produto for disponibilizado você receberá um email avisando.",
                "error": "Não foi possível cadastrar. Tente mais tarde."
            }

## Eventos

Lança os seguintes eventos:

- <b>`vtex.notifyMe.submitted [productId, sku, promise]`</b>: quando a form é enviada.

Escuta pelos seguintes eventos:

- <b>`vtex.sku.selected [productId, sku]`</b>
- <b>`vtex.sku.unselected [productId, selectableSkus]`</b>


---

# Minicart

## Uso

Chame o plugin em uma `div` vazia:

    $('.portal-minicart-ref').minicart(options);

- <b>`options`</b> opcional, é um objeto que pode ter as seguintes propriedades

    - <b>`valuePrefix`</b>
        default: `"R$ "`. Define o texto a ser exibido antes do valor.

    - <b>`valueSufix`</b>
        default: `""`. Define o texto a ser exibido depois do valor.

    - <b>`availabilityMessages`</b>
        Define as mensagens exibidas para cada código de disponibilidade da API. Default:

            {
                "available": "",
                "unavailableItemFulfillment": "Este item não está disponível no momento.",
                "withoutStock": "Este item não está disponível no momento.",
                "cannotBeDelivered": "Este item não está disponível no momento.",
                "withoutPrice": "Este item não está disponível no momento.",
                "withoutPriceRnB": "Este item não está disponível no momento.",
                "nullPrice": "Este item não está disponível no momento."
            }

    - <b>`showMinicart`</b>
        default: `true`. Define se o minicart deve ser mostrado.

    - <b>`showTotalizers`</b>
        default: `true`. Define se o totalizers deve ser mostrado.

## Eventos

Lança os seguintes eventos:

- <b>`vtex.cart.productRemoved []`</b> quando um item é removido pelo minicart.
- <b>`vtex.minicart.mouseOver []`</b>
- <b>`vtex.minicart.mouseOut []`</b>
- <b>`vtex.minicart.updated []`</b>

Escuta pelos seguintes eventos:

- <b>`vtex.cart.productAdded []`</b> o Minicart se atualiza.
- <b>`vtex.cart.productRemoved []`</b> o Minicart se atualiza.


---

# Notas

## Notas gerais

As opções podem ser passadas de três jeitos. Eles são, em ordem de prioridade:

1. Por JavaScript, na chamada do plugin.
2. Com atributos `data-` nos elementos.
3. Modificando as opções padrão (objeto `$.fn.nomeDoPlugin.defaults`).

Após um plugin ser inicializado, o elemento-alvo conterá, em seu objeto `data` (acceso via `$().data()`), uma referência à sua instância do plugin.

## Dependências

|        Plugin        | [jQuery][] | [front.utils][] | [Dust (core)][]|
| :------------------- | --- | --- | --- |
| Sku Selector         |  ✔  |  ✔  |  ✔  |
| Quantity Selector    |  ✔  |  ✗  |  ✔  |
| Accessories Selector |  ✔  |  ✔  |  ✔  |
| Price                |  ✔  |  ✔  |  ✔  |
| Buy Button           |  ✔  |  ✗  |  ✗  |
| Notify Me            |  ✔  |  ✗  |  ✔  |
| Minicart             |  ✔  |  ✔  |  ✔  |


  [jQuery]: http://www.jquery.com
  [front.utils]: https://github.com/vtex/front.utils
  [Dust (core)]: http://linkedin.github.io/dustjs/
