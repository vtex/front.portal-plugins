# Sku Selector

## Dependências

 - [jQuery](http://www.jquery.com)
 - [front.utils](https://github.com/vtex/front.utils)
 - [Liquid.js](https://github.com/gberger42/liquid.js)

## Uso

Chame o plugin em uma `div` vazia:

    $('.sku-selector-container').skuSelector(data, options);

- **`data`**: deve ser um JSON de SKUs padrão da API

- **`options`**: opcional, é um objeto que pode ter as seguintes propriedades
    - **`selectOnOpening`**
        default: `false`. Se `true`, na inicialização do plugin seleciona o primeiro SKU disponível (o primeiro que vier no array).

    - **`warnUnavailable`**
        default: `false`. Se `true`, mostra form de "avise-me" quando um SKU indisponível for selecionado

    - **`showProductImage`**
        default: `false`. Se `true`, mostra a imagem do produto.
        
    - **`showProductTitle`**
        default: `false`. Se `true`, mostra o nome do produto
        
    - **`showPrice`**
        default: `false`. Se `true`, mostra o preço.

    - **`showPriceRange`**
        default: `false`. Se `true`, mostra o preço mínimo e o máximo dentre os SKUs selecionáveis com as dimensões já selecionadas.

## Eventos

- **`vtex.sku.ready`**: ativado quando o Sku Selector é renderizado
- **`vtex.sku.dimensionChanged`**: ativado quando uma dimensão é selecionada
- **`vtex.sku.selected`**: ativado quando um SKU é definido
- **`vtex.sku.unselected`**: ativado quando o SKU torna-se indefinido

---

# Buy Button

## Dependências

 - [jQuery](http://www.jquery.com)
 
## Uso

Chame o plugin na `a` que age como botão de comprar:

    $('.buy-button').buyButton(data, options)
    
- **`data`**: um objeto que **deve** ter a propriedade **`productId`**, e pode também ter `sku`, `qty`, `seller` e `salesChannel`.

- **`options`**: opcional, é um objeto que pode ter as seguintes propriedades

    - **`errorMessage`**
        Mensagem de erro que será alertada se o usuário clicar no botão sem ter escolhido um SKU. Default: *"Por favor, selecione o modelo desejado."*

    - **`redirect`**
        default: `true`. Determina a propriedade de mesmo nome na querystring. **Deve ser `true` para página de produto, e `false` para modal.**

---

# Minicart

## Dependências

 - [jQuery](http://www.jquery.com)
 - [front.utils](https://github.com/vtex/front.utils)
 - [Liquid.js](https://github.com/gberger42/liquid.js)

## Uso

Chame o plugin em uma `div` vazia:

    $('.portal-minicart-ref').minicart(options);
    
- **`options`**: opcional, é um objeto que pode ter as seguintes propriedades

    - **`valuePrefix`**
        default: `"R$ "`. Define o texto a ser exibido antes do valor.
    
    - **`valueSufix`**
        default: `""`. Define o texto a ser exibido depois do valor.
    
    - **`availabilityMessages`**
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
    
    - **`showMinicart`**
        default: `true`. Define se o minicart deve ser mostrado.
    
    - **`showTotalizers`**
        default: `true`. Define se o totalizers deve ser mostrado.
