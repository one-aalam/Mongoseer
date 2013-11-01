express = require 'express'
mongoskin = require 'mongoskin'
path = require 'path'

module.exports = (app) ->
    app.configure 'development', ->
        app.set 'port', process.env.PORT or 9000
        app.set 'views', path.join(app.directory, '/app')
        app.engine 'html', require('ejs').renderFile
        app.set 'view engine', 'html'
        app.use express.favicon()
        app.use express.logger('dev')
        app.use express.bodyParser()
        app.use express.methodOverride()
        app.use express.cookieParser('your secret here')
        app.use express.session()

        app.use app.router
        app.use express.errorHandler()
