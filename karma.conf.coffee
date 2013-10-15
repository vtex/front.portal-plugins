module.exports = (config) ->
	config.set
		files: [
			'build/lib/jquery-1.8.3.min.js',
			'build/lib/vtex-utils.js',
			'build/lib/dust-core-2.0.0.min.js',
			'build/js/portal-sku-selector-with-template.js',
			'build/js/portal-minicart-with-template.js',
			'build/js/portal-sku-selector-with-template.js',
			'build/js/portal-quantity-selector-with-template.js',
			'build/js/portal-accessories-selector-with-template.js',
			'build/js/portal-price-with-template.js',
			'build/js/portal-buy-button.js',
			'build/js/portal-notify-me-with-template.js',
			'build/js/portal-minicart-with-template.js',
			'build/js/portal-sku-measures-with-template.js',
			'spec/helpers/*.js',
			{
				pattern: 'src/**/*.html',
				watched: true,
				included: false,
				served: true
			},
			{
				pattern: 'spec/mocks/**/*.json',
				watched: true,
				included: false,
				served: true
			},
			'spec/**/*.coffee'
		]
		frameworks: ['jasmine']
		browsers: ['PhantomJS']
		preprocessors:
			"**/*.coffee": "coffee"