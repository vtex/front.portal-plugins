### Índice

- [Sku Selector](#sku-selector)
- [Quantity Selector](#quantity-selector)
- [Accessories Selector](#accessories-selector)
- [Buy Button](#buy-button)
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

## Eventos

O Sku Selector lança os seguintes eventos:

- <b>`vtex.sku.ready []`</b> quando o Sku Selector é renderizado.
- <b>`vtex.sku.dimensionChanged [name, value, productId]`</b> quando uma dimensão é selecionada.
- <b>`vtex.sku.selected [sku, productId]`</b> quando um SKU é definido.
- <b>`vtex.sku.unselected [selectableSkus, productId]`</b> quando o SKU torna-se indefinido.


---

# Quantity Selector

## Uso

Chame o plugin em uma `div` vazia:

    $('.quantity-selector-container').skuSelector(productId, quantity, options);

- <b>`productId`</b> o ID do produto.

- <b>`quantity`</b> default: `1`. A quantidade inicial do produto. .

- <b>`options`</b> opcional, é um objeto que pode ter as seguintes propriedades

    - <b>`readonly`</b>
        default: `true`. Define se o input de quantidade deve ter o atributo readonly.

    - <b>`max`</b>
        default: `5`. Define a quantidade máxima que pode ser selecionada.

    - <b>`text`</b>
        default: `"Selecione a quantidade:"`. Define o texto a ser exibido.

    - <b>`style`</b>
        default: `"text"`. Define o tipo de input a ser usado. Opções possíveis: `"text"`, `"select"`, `"number"`

## Eventos

O Quantity Selector lança os seguintes eventos:

- <b>`vtex.quantity.ready [quantity, productId]`</b> na inicialização.
- <b>`vtex.quantity.changed [quantity, productId]`</b> quando a quantidade é mudada.

Adicionalmente, o Quantity Selector escuta pelos seguintes eventos:

- <b>`vtex.quantity.changed [quantity, productId]`</b> a quantidade pode ser mudada por meio de scripts externos e o plugin se atualizará.


---

# Accessories Selector

## Uso

Chame o plugin em uma `div` vazia:

    $('.acc-selector-container').accessoriesSelector(productId, data, options);

- <b>`productId`</b> o ID do produto.

- <b>`data`</b> deve ser um JSON de acessórios padrão da API.

- <b>`options`</b> (nenhuma no momento.)

## Eventos

O Accessories Selector lança os seguintes eventos:

- <b>`vtex.accessory.selected [accessory, productId]`</b> quando um acessório é selecionado ou removido. O objeto `accessory` tem a propriedade `quantity`, que será 0 ou 1, dependendo do caso.


---

# Buy Button

## Uso

Chame o plugin na `a` que age como botão de comprar:

    $('.buy-button').buyButton(productId, data, options);

- <b>`productId`</b> o ID do produto.

- <b>`data`</b> opcional, é um objeto que pode ter as propriedades `sku`, `quantity`, `seller` e `salesChannel`.

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
- <b>`vtex.quantity.changed [quantity, productId]`</b>
- <b>`vtex.accessory.selected [accessory, productId]`</b>


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
| Quantity Selector         |  ✔  |  ✗  |  ✔  |
| Accessories Selector |  ✔  |  ✗  |  ✔  |
| Buy Button           |  ✔  |  ✗  |  ✗  |
| Minicart             |  ✔  |  ✔  |  ✔  |


  [jQuery]: http://www.jquery.com
  [front.utils]: https://github.com/vtex/front.utils
  [Dust (core)]: http://linkedin.github.io/dustjs/
