module.exports = (grunt) ->
	pkg = grunt.file.readJSON('package.json')

	replacements =
		'VERSION': pkg.version

	# Project configuration.
	grunt.initConfig
		relativePath: ''

		# Tasks
		clean:
			main: ['build', 'tmp-deploy']

		copy:
			main:
				expand: true
				cwd: 'src/'
				src: ['**', '!coffee/**', '!**/*.less']
				dest: 'build/<%= relativePath %>'
			mocks:
				src: ['spec/mocks/*.json']
				dest: 'build/<%= relativePath %>/'

		coffee:
			main:
				files: [
					expand: true
					cwd: 'src/coffee'
					src: ['**/*.coffee']
					dest: 'build/<%= relativePath %>/js/'
					ext: '.js'
				]

		less:
			main:
				files:
					'build/<%= relativePath %>/style/portal-sku-selector.css': 'src/style/portal-sku-selector.less'
					'build/<%= relativePath %>/style/product-listing-mock.css': 'src/style/product-listing-mock.less'

		uglify:
			main:
				files:
					'build/js/portal-sku-selector-with-template.min.js': ['build/js/portal-sku-selector-with-template.js']
					'build/js/portal-minicart-with-template.min.js': ['build/js/portal-minicart-with-template.js']
					'build/js/portal-template-as-modal.min.js': ['build/js/portal-template-as-modal.js']

		concat:
			dev:
				files:
					'build/js/portal-sku-selector-with-template.js': ['build/templates/template-sku-selector.js', 'build/js/portal-sku-selector.js']
					'build/js/portal-minicart-with-template.js': ['build/templates/template-minicart.js', 'build/js/portal-minicart.js']
					'build/js/portal-template-as-modal.js': 'build/js/portal-template-as-modal.js'

		karma:
			options:
				configFile: 'karma.conf.coffee'
			unit:
				background: true
			single:
				singleRun: true

		'string-replace':
			main:
				files:
					'build/<%= relativePath %>/index.html': ['build/<%= relativePath %>/index.html']
					'build/<%= relativePath %>/index.debug.html': ['build/<%= relativePath %>/index.debug.html']
				options:
					replacements: ({'pattern': new RegExp(key, "g"), 'replacement': value} for key, value of replacements)

			all:
				files:
					'build/button-bind-modal-api-response.html': ['build/button-bind-modal-api-response.html']

				options:
					replacements: [
						pattern: '<!-- skuSelectorMock -->'
						replacement: grunt.file.read('spec/mocks/threeDimensionsSomeUnavailable.json')
					]

		dustjs:
			compile:
				files:
					'build/templates/template-sku-selector.js': 'src/templates/sku-selector.dust'
					'build/templates/template-minicart.js': 'src/templates/minicart.dust'

		connect:
			main:
				options:
					port: 9001
					base: 'build/'

		remote: main: {}

		watch:
			main:
				options:
					livereload: true
				files: ['src/**/*.html', 'src/**/*.dust', 'src/**/*.coffee', 'spec/**/*.coffee', 'spec/**/*.html', 'src/**/*.js', 'src/**/*.less']
				tasks: ['clean', 'concurrent:transform', 'concat', 'uglify', 'string-replace']

		concurrent:
			transform: ['copy:main', 'copy:mocks', 'coffee', 'less', 'dustjs']

		vtex_deploy:
			main:
				options:
					buildDirectory: 'build'
			dry:
				options:
					buildDirectory: 'build'
					requireEnvironmentType: 'dryrun'
					dryRun: true
			walmart:
				options:
					buildDirectory: 'build'
					bucket: 'vtex-io-walmart'
					requireEnvironmentType: 'stable'

	grunt.loadNpmTasks name for name of pkg.dependencies when name[0..5] is 'grunt-'

	grunt.registerTask 'default', ['clean', 'concurrent:transform', 'concat', 'uglify', 'string-replace', 'server', 'watch:main']
	grunt.registerTask 'dist', ['clean', 'concurrent:transform', 'concat', 'uglify', 'string-replace'] # Dist - minifies files
	grunt.registerTask 'test', ['karma:single']
	grunt.registerTask 'server', ['connect', 'remote']