# Sku Selector

## Dependências

 - [jQuery](http://www.jquery.com)
 - [front.utils](https://github.com/vtex/front.utils)
 - [Liquid.js](https://github.com/gberger42/liquid.js)

## Uso

Chame o plugin em uma `div` vazia:

    $('.sku-selector-container').skuSelector(data, options);

- <b>`data`</b>: deve ser um JSON de SKUs padrão da API

- <b>`options`</b>: opcional, é um objeto que pode ter as seguintes propriedades
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

- <b>`vtex.sku.ready`</b>: ativado quando o Sku Selector é renderizado
- <b>`vtex.sku.dimensionChanged`</b>: ativado quando uma dimensão é selecionada
- <b>`vtex.sku.selected`</b>: ativado quando um SKU é definido
- <b>`vtex.sku.unselected`</b>: ativado quando o SKU torna-se indefinido

---

# Buy Button

## Dependências

 - [jQuery](http://www.jquery.com)

## Uso

Chame o plugin na `a` que age como botão de comprar:

    $('.buy-button').buyButton(data, options)

- <b>`data`</b>: um objeto que <b>deve</b> ter a propriedade <b>`productId`</b>, e pode também ter `sku`, `qty`, `seller` e `salesChannel`.

- <b>`options`</b>: opcional, é um objeto que pode ter as seguintes propriedades

    - <b>`errorMessage`</b>
        Mensagem de erro que será alertada se o usuário clicar no botão sem ter escolhido um SKU. Default: *"Por favor, selecione o modelo desejado."*

    - <b>`redirect`</b>
        default: `true`. Determina a propriedade de mesmo nome na querystring. <b>Deve ser `true` para página de produto, e `false` para modal.</b>

---

# Minicart

## Dependências

 - [jQuery](http://www.jquery.com)
 - [front.utils](https://github.com/vtex/front.utils)
 - [Liquid.js](https://github.com/gberger42/liquid.js)

## Uso

Chame o plugin em uma `div` vazia:

    $('.portal-minicart-ref').minicart(options);

- <b>`options`</b>: opcional, é um objeto que pode ter as seguintes propriedades

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
