# Speedbag

A grunt coffee/less/live-reload/cssmin/uglify/connect/bootstrap/zepto/lodash boilerplate.

Check out the [live demo](http://vtex.github.io/speedbag)

Requires [node](http://nodejs.org/) and [grunt](http://gruntjs.com/) (`npm i -g grunt-cli`).

### Speedstart

    npm i
    grunt

Have fun! Changes to your coffee, less or html files will reload the page automatically. Nice.

The compiled files can be found in the `/build` folder.

### Production build

    grunt prod

### Deployment build

    DEPLOY_ENV=beta GIT_COMMIT=`git rev-parse --verify HEAD` grunt deploy

Have a look at the newly created deploy/master/index.html file.

### Folder structure

- `src` - most of your files will be here.
	- `coffee` - CoffeeScript source files
	- `style` - CSS and LESS source files
	- `lib` - Third-party libs
	- `index.html` - Your app entry point.
- `spec` - Unit tests source files.
- `Gruntfile.coffee` - This is the configuration file for grunt. Contains all the build tasks.
- `remote.json` - The configuration file for [Remote](https://github.com/gadr90/remote), if you need it.
- `build` - this folder will be created after you run a grunt task.
	-   `index.debug.html` - this is the same index as generated on the dev task. Useful for debugging in production.
- `deploy` - this folder contains a deploy-ready, commit-hash-versioned folder of your app
    -   `<git-commit-hash>` - the name of this folder is the hash of your current commit
    -   `versions/<env>` - this folder contains a deployable version of your app

------

### Common issues:

**EADDRINUSE** - Someone is already using one of the ports used by this app, either [connect](https://github.com/gruntjs/grunt-contrib-connect)'s 9001 or [LiveReload](https://github.com/gruntjs/grunt-contrib-livereload)'s 35729.
Shut down interfering services or change the ports on Gruntfile.coffee.

------

VTEX - 2013
