###
Module dependencies.
###
express = require 'express'
http 	= require 'http'
path    = require 'path'
###
Express instance.
###
app 	= express()
###
App directory
###
app.directory = __dirname
###
Load: Environment settings and route
###
require ('./config/environments')(app)
require ('./routes')(app)

# Export...
module.exports = app