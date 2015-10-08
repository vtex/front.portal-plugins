// Karma configuration
// http://karma-runner.github.io/0.12/config/configuration-file.html
// Generated on 2015-10-08 using
// generator-karma 1.0.0

module.exports = function(config) {
  'use strict';

  config.set({
    // enable / disable watching file and executing tests whenever any file changes
    autoWatch: true,

    // base path, that will be used to resolve files and exclude
    basePath: './',

    // testing framework to use (jasmine/mocha/qunit/...)
    // as well as any additional frameworks (requirejs/chai/sinon/...)
    frameworks: [
      "jasmine"
    ],

    // list of files / patterns to load in the browser
    files: [
      {
        pattern: 'http://io.vtex.com.br/front-libs/jquery/1.8.3/jquery-1.8.3.min.js',
        watched: false,
        served: false,
        included: true
      },
      {
        pattern: 'http://io.vtex.com.br/front-libs/bootstrap/3.0.3/js/bootstrap.min.js',
        watched: false,
        served: false,
        included: true
      },
      {
        pattern: 'http://io.vtex.com.br/front-libs/front-utils/1.2.0/vtex-utils.min.js',
        watched: false,
        served: false,
        included: true
      },
      {
        pattern: 'http://io.vtex.com.br/front-libs/dustjs-linkedin/2.3.5/dust-core-2.3.5.js',
        watched: false,
        served: false,
        included: true
      },
      {
        pattern: 'http://io.vtex.com.br/vtex.js/1.0.0/vtex.min.js',
        watched: false,
        served: false,
        included: true
      },
      {
        pattern: 'http://io.vtex.com.br/front-libs/curl/0.8.10-vtex.2/curl.js',
        watched: false,
        served: false,
        included: true
      },
      {
        pattern: 'build/portal-plugins/templates/*.js',
        watched: true,
        included: true,
        served: true
      },
      'src/script/product-component.coffee',
      'src/script/portal-minicart.coffee',
      'src/script/portal-sku-selector.coffee',
      {
        pattern: 'spec/fixtures/*.html',
        watched: true,
        included: false,
        served: true
      },
      {
        pattern: 'src/mocks/**/*.json',
        watched: true,
        included: false,
        served: true
      },
      'spec/helpers/*.js',
      'spec/*.coffee'
    ],

    // list of files / patterns to exclude
    exclude: [
      'src/script/portal-vtex-totem.coffee',
      'src/script/portal-minicart-shipping-data.coffee'
    ],

    // web server port
    port: 8080,

    // Start these browsers, currently available:
    // - Chrome
    // - ChromeCanary
    // - Firefox
    // - Opera
    // - Safari (only Mac)
    // - PhantomJS
    // - IE (only Windows)
    browsers: [
      "PhantomJS"
    ],

    // Which plugins to enable
    plugins: [
      "karma-phantomjs-launcher",
      "karma-jasmine",
      "karma-coffee-preprocessor"
    ],

    preprocessors: {
      '**/*.coffee': ['coffee']
    },

    coffeePreprocessor: {
      // options passed to the coffee compiler
      options: {
        bare: true,
        sourceMap: false
      },
      // transforming the filenames
      transformPath: function(path) {
        return path.replace(/\.coffee$/, '.js')
      }
    },

    // Continuous Integration mode
    // if true, it capture browsers, run tests and exit
    singleRun: false,

    colors: true,

    // level of logging
    // possible values: LOG_DISABLE || LOG_ERROR || LOG_WARN || LOG_INFO || LOG_DEBUG
    logLevel: config.LOG_INFO,

    // Uncomment the following lines if you are using grunt's server to run the tests
    // proxies: {
    //   '/': 'http://localhost:9000/'
    // },
    // URL root prevent conflicts with the site root
    // urlRoot: '_karma_'
  });
};
