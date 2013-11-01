mongoskin = require 'mongoskin'
conn 	  = (db) ->
				mongoskin.db 'localhost:27017/' + db ? 'test', {safe: true}
db        = conn()

module.exports = (app) ->

	'use strict'

	# Route: '/' Available for client-side MVC
	app.get '/', (req, res, next) ->
		res.render 'index',{title:'MongoSeer - Tiny MongoDB client!'}

	# Route: Metadata about local install
	app.get '/api/meta', (req, res, next) ->
			# @todo
			db.admin.listDatabases (err,dbs) ->
				res.json dbs

	# Route: List all databases
	app.get '/api/dbs', (req, res, next) ->
			# Use admin command to list databases
			db.admin.listDatabases (err,dbs) ->
				res.json (db for db in dbs.databases when db.name isnt 'admin')

	# Route: List all collections for provided database
	app.get '/api/dbs/:db', (req, res, next) ->
			# Connect to provided database
			db_this = conn req.params.db
			# Iterate over collections
			db_this.collectionNames (err, collections) ->
			# Return if not system maintained
				res.json (collection.name for collection in collections when collection.name.indexOf('.system.indexes') is -1)

	# Route: List documents in a particular collection
	app.get '/api/dbs/:db/:coll', (req, res, next) ->
			# Connect to provided database
			db_this = conn req.params.db
			# Select a collection
			db_this.collection(req.params.coll).find().toArray (err, result) ->
				res.json result

			