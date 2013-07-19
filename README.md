# Sku Selector

## Dependências

 - [front.utils](https://github.com/vtex/front.utils)

## Uso

    $('.sku-selector-container').skuSelector(data, options);

## data

Deve ser um JSON de SKUs padrão da API

## options

Opcional, é um objeto que pode ter as seguintes propriedades

### selectOnOpening

default: `false`. Se `true`, seleciona o primeiro SKU disponível na inicialização do plugin

### warnUnavailable

default: `false`. Se `true`, mostra form de "avise-me" quando um SKU indisponível for selecionado

### addSkuToCartPreventDefault

default: `true`. Se `true`, dá um `evt.preventDefault()` no evento do botão de compra


# Minicart

## Dependências

 - [front.utils](https://github.com/vtex/front.utils)

## Uso

    $('.portal-minicart-ref').vtexMinicart(options);
    
## options

Opcional, é um objeto que pode ter as seguintes propriedades

### valuePrefix

default: `"R$ "`. Define o texto a ser exibido antes do valor.

### valueSufix

default: `""`. Define o texto a ser exibido depois do valor.