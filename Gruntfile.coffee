path = require('path')
fs = require('fs')

module.exports = (grunt) ->
	pacha = grunt.file.readJSON('tools/pachamama/pachamama.config')[0]
	# Project configuration.
	grunt.initConfig
		gitCommit: process.env['GIT_COMMIT'] or 'GIT_COMMIT'
		deployDirectory: path.normalize(process.env['DEPLOY_DIRECTORY'] ? 'deploy')
		relativePath: ''
		pkg: grunt.file.readJSON('package.json')
		pacha: pacha
		acronym: pacha.acronym
		environmentName: process.env['ENVIRONMENT_NAME'] or '1-0-0'
		buildNumber: process.env['BUILD_NUMBER'] or '1'
		environmentType: process.env['ENVIRONMENT_TYPE'] or 'stable'
		versionName: -> [grunt.config('acronym'), grunt.config('environmentName'), grunt.config('buildNumber'),
										 grunt.config('environmentType')].join('-')
		clean: ['build']
		copy:
			main:
				files: [
					expand: true
					cwd: 'src/'
					src: ['**', '!coffee/**', '!**/*.less']
					dest: 'build/<%= relativePath %>'
				,
					expand: true
					src: ['spec/**', '!**/*.coffee']
					dest: 'build/<%= relativePath %>'
				]

			debug:
				src: ['src/index.html']
				dest: 'build/<%= relativePath %>/index.debug.html'

			deploy:
				expand: true
				cwd: 'build/<%= relativePath %>/'
				src: ['**', '!coffee/**', '!**/*.less']
				dest: '<%= deployDirectory %>/<%= gitCommit %>/'

			env:
				expand: true
				cwd: '<%= deployDirectory %>/<%= gitCommit %>/'
				src: ['**']
				dest: '<%= deployDirectory %>/<%= versionName() %>/'

		coffee:
			main:
				expand: true
				cwd: 'src/coffee'
				src: ['**/*.coffee']
				dest: 'build/<%= relativePath %>/js/'
				ext: '.js'

			test:
				expand: true
				cwd: 'spec/'
				src: ['**/*.coffee']
				dest: 'build/<%= relativePath %>/spec/'
				ext: '.js'

		less:
			main:
				files:
					'build/<%= relativePath %>/style/portal-sku-selector.css': 'src/style/portal-sku-selector.less'
					'build/<%= relativePath %>/style/product-listing-mock.css': 'src/style/product-listing-mock.less'

		useminPrepare:
			html: ['build/<%= relativePath %>/index.html', 'build/<%= relativePath %>/popup.html', 'build/<%= relativePath %>/product.html']

		usemin:
			html: ['build/<%= relativePath %>/index.html', 'build/<%= relativePath %>/popup.html', 'build/<%= relativePath %>/product.html']

		karma:
			options:
				configFile: 'karma.conf.js'
			unit:
				background: true
			deploy:
				singleRun: true

		connect:
			dev:
				options:
					port: 9001
					base: 'build/'

		watch:
			dev:
				options:
					livereload: true
				files: ['src/**/*.html', 'src/**/*.coffee', 'src/**/*.js', 'src/**/*.less', 'spec/**']
				tasks: ['dev']

			prod:
				options:
					livereload: true
				files: ['src/**/*.html', 'src/**/*.coffee', 'src/**/*.js', 'src/**/*.less']
				tasks: ['prod']

			test:
				files: ['src/**/*.html', 'src/**/*.coffee', 'src/**/*.js', 'src/**/*.less', 'spec/**']
				tasks: ['dev', 'karma:unit:run']

		concat:
			dev:
				files:
					'build/js/portal-sku-selector.dev.js': 'build/js/portal-sku-selector.js'
					'build/js/portal-minicart.dev.js': 'build/js/portal-minicart.js'
					'build/js/portal-totalizers.dev.js': 'build/js/portal-totalizers.js'
					'build/js/portal-template-as-modal.dev.js': 'build/js/portal-template-as-modal.js'

		uglify:
			dev:
				files:
					'build/js/portal-sku-selector.min.js': 'build/js/portal-sku-selector.js'
					'build/js/portal-minicart.min.js': 'build/js/portal-minicart.js'
					'build/js/portal-totalizers.min.js': 'build/js/portal-totalizers.js'
					'build/js/portal-template-as-modal.min.js': 'build/js/portal-template-as-modal.js'

		'string-replace':
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

	grunt.loadNpmTasks 'grunt-contrib-connect'
	grunt.loadNpmTasks 'grunt-contrib-concat'
	grunt.loadNpmTasks 'grunt-contrib-copy'
	grunt.loadNpmTasks 'grunt-contrib-clean'
	grunt.loadNpmTasks 'grunt-contrib-coffee'
	grunt.loadNpmTasks 'grunt-contrib-less'
	grunt.loadNpmTasks 'grunt-contrib-uglify'
	grunt.loadNpmTasks 'grunt-contrib-cssmin'
	grunt.loadNpmTasks 'grunt-contrib-watch'
	grunt.loadNpmTasks 'grunt-usemin'
	grunt.loadNpmTasks 'grunt-string-replace'
	grunt.loadNpmTasks 'grunt-karma'
	grunt.loadNpmTasks 'grunt-dustjs'

	grunt.registerTask 'default', ['dev-watch']

	# Dev
	grunt.registerTask 'dev', ['clean', 'copy:main', 'dustjs', 'string-replace:all', 'coffee', 'less', 'concat']
	grunt.registerTask 'dev-watch', ['dev', 'connect', 'remote', 'watch:dev']

	# Prod - minifies files
	grunt.registerTask 'prod', ['dev', 'copy:debug', 'useminPrepare', 'concat', 'uglify', 'usemin']
	grunt.registerTask 'prod-watch', ['prod$(document).on "skuSelected", (evt, sku) ->
	window.FireSkuChangeImage?(sku.sku)
	#window.FireSkuDataReceived?(sku.sku)
	window.FireSkuSelectionChanged?(sku.sku)', 'connect', 'remote', 'watch:prod']

	# Test
	grunt.registerTask 'test', ['dev', 'karma:deploy']
	grunt.registerTask 'test-watch', ['dev', 'karma:unit', 'watch:test']

	# Generates version folder
	grunt.registerTask 'gen-version', ->
		grunt.log.writeln 'Deploying to environmentName: '.cyan + grunt.config('environmentName').green
		grunt.log.writeln 'Deploying to buildNumber: '.cyan + grunt.config('buildNumber').green
		grunt.log.writeln 'Deploying to environmentType: '.cyan + grunt.config('environmentType').green
		grunt.log.writeln 'Directory: '.cyan + grunt.config('versionName')().green
		grunt.log.writeln 'Version set to: '.cyan + grunt.config('gitCommit').green
		grunt.log.writeln 'Deploy folder: '.cyan + grunt.config('deployDirectory').green
		grunt.task.run ['copy:env']

	# Deploy - creates deploy folder structure
	grunt.registerTask 'deploy', ->
		commit = grunt.config('gitCommit')
		deployDir = path.resolve grunt.config('deployDirectory'), commit
		deployExists = false
		grunt.log.writeln 'Version deploy dir set to: '.cyan + deployDir.green
		try
			deployExists = fs.existsSync deployDir
		catch e
			grunt.log.writeln 'Error reading deploy folder'.red
			console.log e

		if deployExists
			grunt.log.writeln 'Folder '.cyan + deployDir.green + ' already exists.'.cyan
			grunt.log.writeln 'Skipping build process and generating environmentType folder.'.cyan
			grunt.task.run ['clean', 'gen-version']
		else
			grunt.task.run ['prod', 'karma:deploy', 'copy:deploy', 'gen-version']

	#	Remote task
	grunt.registerTask 'remote', 'Run Remote proxy server', ->
		require 'coffee-script'
		require('remote')()