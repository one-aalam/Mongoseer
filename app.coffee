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
env 	= require './config/environments'
route   = require './routes'
###
Set: Routes and environment
###
env app
route app
# Export...
module.exports = app