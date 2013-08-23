module.exports = (config) ->
  config.set
    files: [
      'build/lib/jquery-1.8.3.min.js',
      'build/lib/vtex-utils.js',
      'build/lib/dust-core-2.0.0.min.js',
      'build/js/portal-sku-selector-with-template.js',
      'build/js/portal-minicart-with-template.js',
      'spec/helpers/*.js',
    {
      pattern: 'spec/fixtures/**/*.html',
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