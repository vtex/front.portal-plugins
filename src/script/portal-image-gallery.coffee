# DEPENDENCIES:
# jQuery
# jqzoom
# Dust

$ = window.jQuery


# CLASSES
class ImageGallery extends ProductComponent
	constructor: (@element, @productId, @options) ->
		@generateSelectors
			ImageRoot: '.image-root'
			Thumbs: '.thumbs a'
			ThumbArrow: '.thumb-arrow'
			Product: -> $('#produto')

		@images = []
		@bindEvents()
		@initializeGallery()

	bindEvents: =>
		@bindProductEvent 'skuSelectable.vtex', @skuSelectable
		@bindProductEvent 'skuSelected.vtex', @skuSelected

	skuSelected: (evt, productId, sku) =>
		@images = sku.images
		@initializeGallery()

	skuSelectable: (evt, productId, skus) =>
		@images = skus[0].images
		@initializeGallery()

	initializeGallery: =>
		@element.html('')
		@render()

	render: =>
		dust.render 'image-gallery', {images: @images}, (err, out) =>
			throw new Error "ImageGallery Dust error: #{err}" if err
			@element.html out
			if @images.length > 0
				@bindThumbs()
				@changeCurrentImage(@findThumbs().first())

	bindThumbs: =>
		@findThumbs().on 'click', ->
			@changeCurrentImage($(this))

	getIndexFromThumb: (thumb) =>
		+thumb.data('imageGalleryIndex')

	repositionThumbArrow: (thumb) =>
		# Very ugly. Please don't mind.
		thumbLeft = +thumb.left()
		productLeft = +@findProduct().left()
		@findThumbArrow().css
			left: (thumbLeft - productLeft + 30) + 'px'

	changeCurrentImage: (thumb) =>
		@repositionThumbArrow(thumb)
		@findThumbs().removeClass('ON')
		thumb.addClass('ON')

		index = @getIndexFromThumb(thumb)
		dust.render 'image-gallery-single', @images[index], (err, out) =>
			throw new Error "ImageGallery[single] Dust error: #{err}" if err
			el = $(out).appendTo(@findImageRoot())
			if @options.jqzoom && @images[index].zoomUrl
				el.jqzoom(@options.jqzoomOptions)


# EXTENSION
$.fn.left = -> $(this).offset()?.left || 0

# PLUGIN ENTRY POINT
$.fn.imageGallery = (productId, jsOptions) ->
	defaultOptions = $.extend {}, $.fn.imageGallery.defaults
	for element in this
		$element = $(element)
		domOptions = $element.data()
		options = $.extend(true, defaultOptions, domOptions, jsOptions)
		unless $element.data('imageGallery')
			$element.data('imageGallery', new ImageGallery($element, productId, options))

	return this


# PLUGIN DEFAULTS
$.fn.imageGallery.defaults =
	jqzoom: true
	jqzoomOptions:
		preloadText: ""
		title: false
