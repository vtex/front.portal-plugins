
dependencies = [
  'flight/lib/component'
]

vtex.define dependencies, (defineComponent, shippingOptionsTemplate) ->

  ShippingOptions = ->

    @after 'initialize', ->


  defineComponent(ShippingOptions)