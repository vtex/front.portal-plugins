### Índice

- [Sku Selector](#sku-selector)
- [Qty Selector](#qty-selector)
- [Buy Button](#buy-button)
- [Minicart](#minicart)


---

# Sku Selector

## Uso

Chame o plugin em uma `div` vazia:

    $('.sku-selector-container').skuSelector(data, options);

- <b>`data`</b> deve ser um JSON de SKUs padrão da API.

- <b>`options`</b> opcional, é um objeto que pode ter as seguintes propriedades:
    - <b>`selectOnOpening`</b>
        default: `false`. Se `true`, na inicialização do plugin seleciona o primeiro SKU disponível (o primeiro que vier no array).

    - <b>`warnUnavailable`</b>
        default: `false`. Se `true`, mostra form de "avise-me" quando um SKU indisponível for selecionado.

    - <b>`showProductImage`</b>
        default: `false`. Se `true`, mostra a imagem do produto.

    - <b>`showProductTitle`</b>
        default: `false`. Se `true`, mostra o nome do produto.

    - <b>`showPrice`</b>
        default: `false`. Se `true`, mostra o preço.

    - <b>`showPriceRange`</b>
        default: `false`. Se `true`, mostra o preço mínimo e o máximo dentre os SKUs selecionáveis com as dimensões já selecionadas.

### confirmBuy

default: `false`. Se `true`, ao clicar no botão de compra é mostrado um botão de confirmação, com as dimensões selecionadas.

### showBuyButton

default: `false`. Se `true`, mostra o botão de comprar.

### showProductImage

## Eventos

O Sku Selector lança os seguintes eventos:

- <b>`vtex.sku.ready []`</b> quando o Sku Selector é renderizado.
- <b>`vtex.sku.dimensionChanged [name, value, productId]`</b> quando uma dimensão é selecionada.
- <b>`vtex.sku.selected [sku, productId]`</b> quando um SKU é definido.
- <b>`vtex.sku.unselected [selectableSkus, productId]`</b> quando o SKU torna-se indefinido.


---

# Qty Selector

## Uso

Chame o plugin em uma `div` vazia:

    $('.qty-selector-container').skuSelector(productId, qty, options);

- <b>`productId`</b> o ID do produto.

- <b>`qty`</b> default: `1`. A quantidade inicial do produto. .

- <b>`options`</b> opcional, é um objeto que pode ter as seguintes propriedades

    - <b>`readonly`</b>
        default: `true`. Define se o input de quantidade deve ter o atributo readonly.

    - <b>`max`</b>
        default: `5`. Define a quantidade máxima que pode ser selecionada.

    - <b>`text`</b>
        default: `"Selecione a quantidade:"`. Define o texto a ser exibido.

    - <b>`style`</b>
        default: `"text"`. Define o tipo de input a ser usado. Opções possíveis: `"text"`, `"select"`, `"number"`


## Eventos:

O Qty Selector lança os seguintes eventos:

- <b>`vtex.qty.ready [qty, productId]`</b> na inicialização.
- <b>`vtex.qty.changed [qty, productId]`</b> quando a quantidade é mudada.

Adicionalmente, o Qty Selector escuta pelos seguintes eventos:

- <b>`vtex.qty.changed [qty, productId]`</b> a quantidade pode ser mudada por meio de scripts externos e o plugin se atualizará.


---

# Buy Button

## Uso

Chame o plugin na `a` que age como botão de comprar:

    $('.buy-button').buyButton(productId, data, options);

- <b>`productId`</b> o ID do produto.

- <b>`data`</b> opcional, é um objeto que pode ter as propriedades `sku`, `qty`, `seller` e `salesChannel`.

- <b>`options`</b> opcional, é um objeto que pode ter as seguintes propriedades

    - <b>`errorMessage`</b>
        Mensagem de erro que será alertada se o usuário clicar no botão sem ter escolhido um SKU. Default: *"Por favor, selecione o modelo desejado."*

    - <b>`redirect`</b>
        default: `true`. Determina a propriedade de mesmo nome na querystring. <b>Deve ser `true` para página de produto, e `false` para modal.</b>

## Eventos

O Buy Button lança os seguintes eventos:

- <b>`vtex.modal.hide []`</b> quando `redirect=false` e o botão é clicado.
- <b>`vtex.cart.productAdded []`</b> quando `redirect=false`, o botão é clicado e a resposta do AJAX volta.

Adicionalmente, o Buy Button escuta pelos seguintes eventos:

- <b>`vtex.sku.selected [sku, productId]`</b>
- <b>`vtex.sku.unselected [selectableSkus, productId]`</b>
- <b>`vtex.qty.changed [qty, productId]`</b>


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

O Minicart lança os seguintes eventos:

- <b>`vtex.cart.productRemoved []`</b> quando um item é removido pelo minicart.
- <b>`vtex.minicart.mouseOver []`</b>
- <b>`vtex.minicart.mouseOut []`</b>
- <b>`vtex.minicart.updated []`</b>

Adicionalmente, o Minicart escuta pelos seguintes eventos:

- <b>`vtex.cart.productAdded []`</b> o Minicart se atualiza.


---

# Dependências

| Plugin       | [jQuery][] | [front.utils][] | [Dust (core)][]|
| :----------- | --- | --- | --- |
| Sku Selector |  ✔  |  ✔  |  ✔  |
| Qty Selector |  ✔  |  ✗  |  ✔  |
| Buy Button   |  ✔  |  ✗  |  ✗  |
| Minicart     |  ✔  |  ✔  |  ✔  |


  [jQuery]: http://www.jquery.com
  [front.utils]: https://github.com/vtex/front.utils
  [Dust (core)]: http://linkedin.github.io/dustjs/
  [Dust (helpers)]: https://github.com/linkedin/dustjs-helpers
