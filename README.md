# Sku Selector

## Uso

Chame o plugin em uma `div` vazia:

    $('.sku-selector-container').skuSelector(data, options);

- <b>`data`</b> deve ser um JSON de SKUs padrão da API

- <b>`options`</b> opcional, é um objeto que pode ter as seguintes propriedades
    - <b>`selectOnOpening`</b>
        default: `false`. Se `true`, na inicialização do plugin seleciona o primeiro SKU disponível (o primeiro que vier no array).

    - <b>`warnUnavailable`</b>
        default: `false`. Se `true`, mostra form de "avise-me" quando um SKU indisponível for selecionado

    - <b>`showProductImage`</b>
        default: `false`. Se `true`, mostra a imagem do produto.

    - <b>`showProductTitle`</b>
        default: `false`. Se `true`, mostra o nome do produto

    - <b>`showPrice`</b>
        default: `false`. Se `true`, mostra o preço.

    - <b>`showPriceRange`</b>
        default: `false`. Se `true`, mostra o preço mínimo e o máximo dentre os SKUs selecionáveis com as dimensões já selecionadas.

## Eventos

O Sku Selector lança os seguintes eventos:

- <b>`vtex.sku.ready`</b> quando o Sku Selector é renderizado
- <b>`vtex.sku.dimensionChanged`</b> quando uma dimensão é selecionada
- <b>`vtex.sku.selected`</b> quando um SKU é definido
- <b>`vtex.sku.unselected`</b> quando o SKU torna-se indefinido


---

# Buy Button

## Uso

Chame o plugin na `a` que age como botão de comprar:

    $('.buy-button').buyButton(data, options);

- <b>`data`</b> um objeto que <b>deve</b> ter a propriedade <b>`productId`</b>, e pode também ter `sku`, `qty`, `seller` e `salesChannel`.

- <b>`options`</b> opcional, é um objeto que pode ter as seguintes propriedades

    - <b>`errorMessage`</b>
        Mensagem de erro que será alertada se o usuário clicar no botão sem ter escolhido um SKU. Default: *"Por favor, selecione o modelo desejado."*

    - <b>`redirect`</b>
        default: `true`. Determina a propriedade de mesmo nome na querystring. <b>Deve ser `true` para página de produto, e `false` para modal.</b>

## Eventos

O Buy Button lança os seguintes eventos:

- <b>`vtex.modal.hide`</b> quando `redirect=false` e o botão é clicado
- <b>`vtex.cart.productAdded`</b> quando `redirect=false`, o botão é clicado e a resposta do AJAX volta

Adicionalmente, o Buy Button escuta pelos seguintes eventos:

- <b>`vtex.sku.selected`</b>
- <b>`vtex.sku.unselected`</b>
- <b>`vtex.qty.changed`</b>


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

- <b>`vtex.cart.productRemoved`</b> quando um item é removido pelo minicart
- <b>`vtex.minicart.mouseOver`</b>
- <b>`vtex.minicart.mouseOut`</b>
- <b>`vtex.minicart.updated`</b>

Adicionalmente, o Minicart escuta pelos seguintes eventos:

- <b>`vtex.cart.productAdded`</b> o Minicart se atualiza


---

# Dependências

| Plugin       | [jQuery][] | [front.utils][] | [Dust][]|
| ------------ | --- | --- | --- |
| Sku Selector |  ✔  |  ✔  |  ✔  |
| Buy Button   |  ✔  |  ✗  |  ✗  |
| Minicart     |  ✔  |  ✔  |  ✔  |


  [jQuery]: http://www.jquery.com
  [front.utils]: https://github.com/vtex/front.utils
  [Dust]: http://linkedin.github.io/dustjs/