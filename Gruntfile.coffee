GruntVTEX = require 'grunt-vtex'

module.exports = (grunt) ->
  pkg = grunt.file.readJSON 'package.json'

  config = GruntVTEX.generateConfig grunt, pkg,
    open: 'http://basedevmkp.vtexlocal.com.br/portal-plugins/'

  config.dust =
    files:
      expand: true
      cwd: 'src/templates/'
      src: ['**/*.dust']
      dest: 'build/<%= relativePath %>/templates/'
      ext: '.js'
    options:
      relative: true
      runtime: false
      wrapper: false

  config.watch.dust =
    files: ['src/templates/**/*.dust']
    tasks: ['dust', 'concat']

  config.watch.coffee.tasks = ['coffee', 'copy:js', 'concat']

  config.clean.deploy = 'build/<%= relativePath %>/script/'

  config.karma =
    options:
      configFile: 'karma.conf.js'
    unit:
      singleRun: true

  # Copy all to 'js' for Portal URLs compatibility, e.g. "http://io.vtex.com.br/portal-plugins/2.7.3/js/portal-template-as-modal.min.js"
  config.copy.js =
    files: [
      expand: true
      cwd: 'build/<%= relativePath %>/script/'
      src: ['**/*.js']
      dest: "build/<%= relativePath %>/js/"
    ]

  # 'js' instead of 'script' for Portal URLs compatibility, e.g. "http://io.vtex.com.br/portal-plugins/2.7.3/js/portal-minicart-with-template.min.js"
  config.concat =
    main:
      files:
        'build/<%= relativePath %>/js/portal-image-gallery-with-template.js': ['build/<%= relativePath %>/script/product-component.js', 'build/<%= relativePath %>/templates/image-gallery.js', 'build/<%= relativePath %>/templates/image-gallery-single.js', 'build/<%= relativePath %>/script/portal-image-gallery.js']
        'build/<%= relativePath %>/js/portal-sku-selector-with-template.js': ['build/<%= relativePath %>/script/product-component.js', 'build/<%= relativePath %>/templates/sku-selector-modal.js', 'build/<%= relativePath %>/templates/sku-selector-product.js', 'build/<%= relativePath %>/script/portal-sku-selector.js']
        'build/<%= relativePath %>/js/portal-quantity-selector-with-template.js': ['build/<%= relativePath %>/script/product-component.js', 'build/<%= relativePath %>/templates/quantity-selector.js', 'build/<%= relativePath %>/script/portal-quantity-selector.js']
        'build/<%= relativePath %>/js/portal-accessories-selector-with-template.js': ['build/<%= relativePath %>/script/product-component.js', 'build/<%= relativePath %>/templates/accessories-selector.js', 'build/<%= relativePath %>/script/portal-accessories-selector.js']
        'build/<%= relativePath %>/js/portal-price-with-template.js': ['build/<%= relativePath %>/script/product-component.js', 'build/<%= relativePath %>/templates/price.js', 'build/<%= relativePath %>/templates/price-modal.js', 'build/<%= relativePath %>/script/portal-price.js']
        'build/<%= relativePath %>/js/portal-buy-button.js': ['build/<%= relativePath %>/script/product-component.js', 'build/<%= relativePath %>/script/portal-buy-button.js']
        'build/<%= relativePath %>/js/portal-notify-me-with-template.js': ['build/<%= relativePath %>/script/product-component.js', 'build/<%= relativePath %>/templates/notify-me.js', 'build/<%= relativePath %>/script/portal-notify-me.js']
        'build/<%= relativePath %>/js/portal-minicart-with-template.js': ['build/<%= relativePath %>/script/product-component.js', 'build/<%= relativePath %>/templates/minicart.js', 'build/<%= relativePath %>/script/portal-minicart.js']
        'build/<%= relativePath %>/js/portal-sku-measures-with-template.js': ['build/<%= relativePath %>/script/product-component.js', 'build/<%= relativePath %>/templates/sku-measures.js', 'build/<%= relativePath %>/script/portal-sku-measures.js']
        'build/<%= relativePath %>/js/portal-shipping-calculator-with-template.js': ['build/<%= relativePath %>/script/product-component.js', 'build/<%= relativePath %>/templates/shipping-calculator.js', 'build/<%= relativePath %>/script/portal-shipping-calculator.js']

  config.uglify =
    main:
      files: [
        expand: true,
        cwd: 'build/<%= relativePath %>/js',
        src: '**/*.js',
        dest: 'build/<%= relativePath %>/js'
        rename: (dest, src) -> dest + '/' + src.replace('.js', '.min.js')
      ]

  tasks =
  # Building block tasks
    build: ['clean', 'copy:main', 'copy:pkg', 'coffee', 'copy:js', 'dust', 'concat']
  # Deploy tasks
    dist: ['build', 'uglify:main', 'clean:deploy', 'copy:deploy'] # Dist - minifies files
    test: ['dust', 'karma:unit']
    vtex_deploy: ['shell:cp', 'shell:cp_br']
  # Development tasks
    dev: ['nolr', 'build', 'watch']
    default: ['build', 'connect', 'watch']
    devmin: ['build', 'min', 'connect:http:keepalive'] # Minifies files and serve

  # Project configuration.
  grunt.initConfig config
  grunt.loadNpmTasks name for name of pkg.devDependencies when name[0..5] is 'grunt-' and name isnt 'grunt-vtex'
  grunt.registerTask 'nolr', ->
    # Turn off LiveReload in development mode
    grunt.config 'watch.options.livereload', false
    return true
  grunt.registerTask taskName, taskArray for taskName, taskArray of tasks
