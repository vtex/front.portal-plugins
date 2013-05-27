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
				expand: true
				cwd: 'src/'
				src: ['**', '!includes/**', '!coffee/**', '!**/*.less']
				dest: 'build/<%= relativePath %>'

			debug:
				src: ['src/index.html']
				dest: 'build/<%= relativePath %>/index.debug.html'

			deploy:
				expand: true
				cwd: 'build/<%= relativePath %>/'
				src: ['**', '!includes/**', '!coffee/**', '!**/*.less']
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

		useminPrepare:
			html: ['build/<%= relativePath %>/index.html', 'build/<%= relativePath %>/popup.html', 'build/<%= relativePath %>/product.html']

		usemin:
			html: ['build/<%= relativePath %>/index.html', 'build/<%= relativePath %>/popup.html', 'build/<%= relativePath %>/product.html']

		jasmine:
			test:
				src: ['build/<%= relativePath %>/lib/zepto/zepto.js', 'build/<%= relativePath %>/js/**/*.js']
				options:
					specs: 'build/<%= relativePath %>/spec/*Spec.js'

		connect:
			dev:
				options:
					port: 9001
					base: 'build/'

		watch:
			options:
				livereload: true

			dev:
				files: ['src/**/*.html', 'src/**/*.coffee', 'src/**/*.js', 'src/**/*.less']
				tasks: ['dev']

			prod:
				files: ['src/**/*.html', 'src/**/*.coffee', 'src/**/*.js', 'src/**/*.less']
				tasks: ['prod']

			test:
				files: ['src/**/*.html', 'src/**/*.coffee', 'src/**/*.js', 'src/**/*.less', 'spec/**/*.coffee']
				tasks: ['test']
				spawn: true

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

	grunt.registerTask 'default', ['dev-watch']

	# Dev
	grunt.registerTask 'dev', ['clean', 'copy:main', 'coffee', 'less']
	grunt.registerTask 'dev-watch', ['dev', 'connect', 'remote', 'watch:dev']

	# Prod - minifies files
	grunt.registerTask 'prod', ['dev', 'copy:debug', 'useminPrepare', 'concat', 'uglify', 'usemin']
	grunt.registerTask 'prod-watch', ['prod', 'connect', 'remote', 'watch:prod']

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
			grunt.task.run ['prod', 'copy:deploy', 'gen-version']

	#	Remote task
	grunt.registerTask 'remote', 'Run Remote proxy server', ->
		require 'coffee-script'
		require('remote')()