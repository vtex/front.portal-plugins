### Table of contents

- Plugins
    - [Sku Selector](#sku-selector)
    - [Quantity Selector](#quantity-selector)
    - [Accessories Selector](#accessories-selector)
    - [Price](#price)
    - [ShippingCalculator](#shipping-calculator)
    - [Buy Button](#buy-button)
    - [Notify Me](#notify-me)
    - [Minicart](#minicart)
    - [Expiration](#expiration)

- [Notes](#notas)


---

See also in [Portuguese](https://github.com/vtex/front.portal-plugins/blob/master/README.pt-BR.md).

---

# Sku Selector

## Usage

Call the plugin in an empty `div`:

    $('.sku-selector-container').skuSelector(data, options);

- <b>`data`</b> must be a JSON with API standard SKUs.

- <b>`options`</b>  (optional) is an object that may have the following properties:
    - <b>`selectOnOpening`</b>
        default: `false`. If `true`, at initialization the plugin selects the first available SKU (the first one that comes in the array).

    - <b>`modalLayout`</b>
        default: `false`. If `true`, it uses the modal template.

    - <b>`warnUnavailable`</b>
        default: `false`. If `true`, it shows "notify me" form when an unavailable SKU is selected.

    - <b>`showPriceRange`</b>
        default: `false`. If `true`, it shows the minimum and maximum price among the selectable SKUs with the dimensions already selected.

    - <b>`forceInputType`</b>
        default: `null`. If not falsy, it forces the inputType of all dimensions to be that.

## Events

Triggers the following events:

- <b>`skuReady.vtex []`</b> when the SKU Selector is rendered.
- <b>`skuDimensionChanged.vtex [productId, name, value]`</b> when a dimension is selected.
- <b>`skuSelected.vtex [productId, sku]`</b> when an SKU is defined.
- <b>`skuUnselected.vtex [productId, selectableSkus]`</b> when the SKU becomes undefined.


---

# Quantity Selector

## Usage

Call the plugin in an empty `div`:

    $('.quantity-selector-container').quantitySelector(productId, options);

- <b>`productId`</b> the product ID.

- <b>`options`</b> (optional) is an object that may have the following properties:

    - <b>`unitBased`</b>
        default: `false`. Defines whether to use bulk selector (quantity calculator).

    - <b>`unitVariations`</b>
        default: `[]`. If `unitBased == true`, specifies the unit options for each SKU. It is a collection of `{skuId: Number, measurementUnit: String, unitMultiplier: Number}`.

    - <b>`max`</b>
        default: `10`. Defines the maximum amount that can be selected.

    - <b>`initialQuantity`</b>
        default: `1`. Sets the quantity initially selected.

    - <b>`decimalPlaces`</b>
        default: `2`. Sets the number of decimal places for the units input. It should not exceed 12.


## Events

Triggers the following events:

- <b>`quantityReady.vtex [productId, quantity]`</b> when the Quantity Selector is rendered.
- <b>`quantityChanged.vtex [productId, quantity]`</b> when quantity is changed.

It listens for the following events:

- <b>`quantityChanged.vtex [productId, quantity]`</b> The quantity can be changed through external scripts and the plugin will be updated.


---

# Accessories Selector

## Usage

Call the plugin in an empty `div`:

    $('.acc-selector-container').accessoriesSelector(productId, data, options);

- <b>`productId`</b> the product ID which is the accessories’ parent.

- <b>`data`</b> must be a JSON with API standard accessories.

- <b>`options`</b> (none currently.)

## Events

Triggers the following events:

- <b>`accessoriesUpdated.vtex [productId, accessories]`</b> when an accessory is changed. The `accessories` array contains the accessories of a particular product, with properties like `sku` and `quantity`.


---

# Price

Listens for changes in the selected SKU and updates the price labels.

Uses standard price information when there is no SKU selected.

## Usage

Call the plugin in an empty `div`. If it contains some HTML, it will be used when a Sku is not defined.

    $('.productPrice').price(productId, options);

- <b>`productId`</b> the product ID.

- <b>`options`</b> (optional) is an object that can have the following properties

    - <b>`originalSku`</b>
        default: `null`. Must be set if the above option is `true`.

    - <b>`modalLayout`</b>
        default: `false`. If `true`, it uses the modal template.

## Events

Listens for the following events:

- <b>`skuSelected.vtex [productId, sku]`</b>
- <b>`skuUnselected.vtex [productId, selectableSkus]`</b>


---

# Shipping Calculator

Offers a form for calculating shipping, plus a button to show it.

## Usage

Call the plugin in an empty `div`.

    $('.shipping-calc-ref').shippingCalculator(productId, options);

- <b>`productId`</b> the product ID.

- <b>`options`</b> (optional) is an object that can have the following properties:

    - <b>`strings`</b>
        Sets the messages to be displayed.
        
        Default:
        ```
        {
            "calculateShipping": 'Calcule o valor do frete e prazo de entrega para a sua região:',
            "enterPostalCode": 'Calcular o valor do frete e verificar disponibilidade:',
            "requiredPostalCode": 'O CEP deve ser informado.',
            "invalidPostalCode": 'CEP inválido.',
            "requiredQuantity": 'É necessário informar a quantidade do mesmo Produto.',
            "siteName": 'Vtex.Commerce.Web.CommerceContext.Current.WebSite.Name',
            "close": 'Fechar'
        }
        ```
        
        Suggested english version:
        ```
        {
            "calculateShipping": 'Calculate the shipping value and delivery deadline for your region:',
            "enterPostalCode": 'Calculate the shipping value and check availability:',
            'requiredPostalCode': 'The ZIP code must be informed.',
            'invalidPostalCode': 'Invalid ZIP code.',
            'requiredQuantity': 'You must enter the quantity of the same Product.',
            "siteName": 'Vtex.Commerce.Web.CommerceContext.Current.WebSite.Name',
            "close": 'Close'
        }
        ```

## Events

Listens for the following events:

- <b>`skuSelected.vtex [productId, sku]`</b>
- <b>`skuUnselected.vtex [productId, selectableSkus]`</b>
- <b>`quantityReady.vtex [productId, quantity]`</b>
- <b>`quantityChanged.vtex [productId, quantity]`</b>


---

# Buy Button

## Usage

Call the plugin on the `a` that acts as a buy button:

    $('.buy-button').buyButton(productId, data, options);

- <b>`productId`</b> the product ID. It may be an array of product IDs - in such case, it will be a button that enables buying all products at the same time.

- <b>`data`</b> (optional) is an object that can have the `sku`, `quantity`, `seller` and `salesChannel` properties.

- <b>`options`</b> (optional) is an object that may have the following properties.

    - <b>`errorMessage`</b>
        Error message to be triggered if the user clicks the button without having chosen an SKU. This message will appear in the parameters of the `vtex.buyButton.failedAttempt` event.
        Default: *"Please select the desired template."*

    - <b>`alertOnError`</b>
        default: `true`. Determines whether to display an alert with the `errorMessage`.

    - <b>`redirect`</b>
        default: `true`. Sets the `Redirect` property in the querystring. <b>Must be `true` for product page, and `false` for modal.</b>

    - <b>`instaBuy`</b>
        default: `false`. If `true`, when an available SKU is selected, the button is clicked.

    - <b>`hideUnselected`</b>
        default: `false`. If `true`, it is hidden when there is no SKU selected.

    - <b>`hideUnavailable`</b>
        default: `false`. If `true`, it is hidden when the selected SKU is unavailable.

    - <b>`target`</b>
        default: `null`. Sets the `target` query parameter. A valid value is `"orderform"`.

    - <b>`requireAllSkus`</b>
        default: `false`. If `productId` is an array, this option determines whether all product IDs must have an SKU selected, or whether partial purchases are accepted (only for those selected).

## Events

Triggers the following events:

- <b>`modalHide.vtex []`</b>  when `redirect=false` and the button is clicked.
- <b>`cartProductAdded.vtex []`</b> when `redirect=false`, the button is clicked and the AJAX response is returned.
- <b>`buyButtonFailedAttempt.vtex [errorMessage]`</b> when the button is clicked but there’s no valid SKU.
- <b>`buyButtonThrough.vtex [url]`</b> when the button is clicked and there is a valid SKU.

Listens for the following events:

- <b>`skuSelected.vtex [productId, sku]`</b>
- <b>`skuUnselected.vtex [productId, selectableSkus]`</b>
- <b>`quantityChanged.vtex [productId, quantity]`</b>
- <b>`accessorySelected.vtex [productId, accessory]`</b>


---

# Notify Me

## Usage

Call the plugin in an empty `div`:

    $('.portal-notify-me-ref').notifyMe(productId, options);

- <b>`productId`</b> the product ID.

- <b>`options`</b> (opcional) is an object that may have the following properties.

    - <b>`ajax`</b>
        default: `true`. Defines whether the form submit should be done with AJAX.

    - <b>`sku`</b>
        default: `null`. Sets the SKU to be used. If it exists, it ignores SKU selection events.

    - <b>`strings`</b>
        Sets the messages to be displayed.
        
        Default:
        ```
        {
            "title": "",
            "explanation": "Para ser avisado da disponibilidade deste Produto, basta preencher os campos abaixo.",
            "namePlaceholder": "Digite seu nome...",
            "emailPlaceholder": "Digite seu e-mail...",
            "loading": "Carregando...",
            "success": "Cadastrado com sucesso. Assim que o produto for disponibilizado você receberá um email avisando.",
            "error": "Não foi possível cadastrar. Tente mais tarde."
        }
        ```
        
        Suggested english version:
        ```
        {
            "title": "",
            "explanation": "To be notified of the availability of this Product, just fill in the fields below.",
            "namePlaceholder": "Enter your name...",
            "emailPlaceholder": "Enter your email...",
            "loading": "Loading...",
            "success": "Successfully registered. As soon as the product is made available you will receive an email notifying you.",
            "error": "Registration failed, please try again later."
        }
        ```

## Events

Triggers the following events:

- <b>`notifyMeSubmitted.vtex [productId, sku, promise]`</b>: when the form is sent.

Listens for the following events:

- <b>`skuSelected.vtex [productId, sku]`</b>
- <b>`skuUnselected.vtex [productId, selectableSkus]`</b>


---

# Minicart

## Usage

Call the plugin in an empty `div`:

    $('.portal-minicart-ref').minicart(options);

- <b>`options`</b> (optional) is an object that may have the following properties

    - <b>`valuePrefix`</b>
        default: `"R$ "`. Sets the text to be displayed before the value.

    - <b>`valueSufix`</b>
        default: `""`. Sets the text to be displayed after the value.

    - <b>`availabilityMessages`</b>
        Sets the messages displayed for each API availability code.
        
        Default:
        ```
        {
            "available": "",
            "unavailableItemFulfillment": "Este item não está disponível no momento.",
            "withoutStock": "Este item não está disponível no momento.",
            "cannotBeDelivered": "Este item não está disponível no momento.",
            "withoutPrice": "Este item não está disponível no momento.",
            "withoutPriceRnB": "Este item não está disponível no momento.",
            "nullPrice": "Este item não está disponível no momento."
        }
        ```
        Suggested english version:
        ```
        {
            "available": "",
            "unavailableItemFulfillment": "This item is currently unavailable.",
            "withoutStock": "This item is currently unavailable.",
            "cannotBeDelivered": "This item is currently unavailable.",
            "withoutPrice": "This item is currently unavailable.",
            "withoutPriceRnB": "This item is currently unavailable.",
            "nullPrice": "This item is currently unavailable."
        }
        ```

    - <b>`showMinicart`</b>
        default: `true`. Defines whether the minicart should be displayed.

    - <b>`showTotalizers`</b>
        default: `true`. Defines whether the totalizers should be displayed.

## Events

Triggers the following events:

- <b>`cartProductRemoved.vtex []`</b> when an item is removed by the minicart.
- <b>`minicartMouseOver.vtex  []`</b>
- <b>`minicartMouseOut.vtex  []`</b>
- <b>`minicartUpdated.vtex  []`</b>

Listens for the following events:

- <b>`cartProductAdded.vtex  []`</b> the Minicart is updated.
- <b>`cartProductRemoved.vtex  []`</b> the Minicart is updated.


---

# Expiration

## session-expiration.js

Utilitary expiration timer, reset by events. When time expires, the user session is cleaned up (cookies are cleared) and the user is redirected to a URL.

### Public functions

#### vtex.portal.startExpiration(url, millis, events)

Start expiration timer.

Parameters and defaults:

- url = '/'
- millis = 10 * 60 * 1000 (10 minutes)
- events = ["mousemove", "keyup", "click", "scroll"]

#### vtex.portal.stopExpiration()

Stops current expiration timer.


---

# Notes

## General notes

The options can be passed in three ways. They are, in order of priority:

1. Through JavaScript, in the plugin request.
2. With `data-` attributes in the elements..
3. Changing the default options (object `$.fn.nomeDoPlugin.default`).

After a plugin is initialized, the target element will contain, in its `data` object (access via `$().data())`, a reference to its plugin instance.

## Dependências

|        Plugin        | [jQuery][] | [front.utils][] | [Dust (core)][]| Catalog SDK |
| :------------------- | --- | --- | --- | --- |
| Sku Selector         |  ✔  |  ✔  |  ✔  |  ✗  |
| Quantity Selector    |  ✔  |  ✗  |  ✔  |  ✗  |
| Accessories Selector |  ✔  |  ✔  |  ✔  |  ✗  |
| Price                |  ✔  |  ✔  |  ✔  |  ✗  |
| Shipping Calculator  |  ✔  |  ✗  |  ✔  |  ✔  |
| Buy Button           |  ✔  |  ✗  |  ✗  |  ✔  |
| Notify Me            |  ✔  |  ✗  |  ✔  |  ✔  |
| Minicart             |  ✔  |  ✔  |  ✔  |  ✗  |
| Expiration           |  ✔  |  ✗  |  ✗  |  ✗  |


  [jQuery]: http://www.jquery.com
  [front.utils]: https://github.com/vtex/front.utils
  [Dust (core)]: http://linkedin.github.io/dustjs/
