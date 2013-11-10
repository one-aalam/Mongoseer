# Mongoskin import
mongoskin = require 'mongoskin'
# Server options
so 		  = 
	auto_reconnect: true 
	poolSize: 5
	safe: true
# Connect callback
conn 	  = (db = 'test') ->
				mongoskin.db 'localhost:27017/' + db, so
# Vars
db        = conn()
conn      = ''
admin     = ''
connections = {}
databases   = []
collections = {}
# DB Callbacks

dbCollRefresh = (conn, dbName) ->
	conn.collectionNames (err, cNames) ->
		cNames = (cName.name.split('.').splice(1,cName.name.length).join('.') for cName in cNames)
		cNames = (cName for cName in cNames when cName isnt 'system.indexes')
		collections[dbName] = cNames.sort()

dbRefresh 	= (admin) ->
	admin.listDatabases (err, dbs) ->
		if err then console.log err 
		# Databases: allowed
		databases = (db.name for db in dbs.databases when db.name isnt 'local')
		# Connections: permitted
		connections[db] = conn.db(db) for db in databases
		# Collection: refresh
		dbCollRefresh(conn, db) for db, conn of connections
		databases = databases.sort()

dbPadRequest = (req, res, next) ->
	req.admin = admin
	req.databases = databases
	req.collections = collections
	next()




db.open (err, dbLocal) ->
	if err then throw err
	conn = dbLocal

	dbLocal.admin (e, dbAdmin) ->
		admin = dbAdmin
		dbRefresh(dbAdmin)
				

module.exports = (app) ->

	'use strict'

	# Param pre-conditions
	app.param 'db', (req, res, next, db) ->
		#if databases[db]? then req.dbName = db else req.session.error = 'DB missing'
		req.dbName = db
		if connections[db]?
  			req.db = connections[db]
		else
  			connection[db] = conn.db(db)
  			req.db = connections[db]
		next()

	app.param 'coll', (req, res, next, collName) ->
		if collections[req.dbName]?
			req.collName = collName
		else 
			req.session.error = 'Coll missing'

		req.db.collection collName, (err, coll) ->
			if err or !coll
				console.log 'Collection error'
			else
				req.coll = coll
		next()

	# Route: '/' Available for client-side MVC
	app.get '/', (req, res, next) ->
		res.render 'index',{title:'MongoSeer - Tiny MongoDB client!'}

	# Route: Metadata about local install
	app.get '/api/meta', (req, res, next) ->
			# @todo
			db.admin.listDatabases (err,dbs) ->
				res.json dbs

	# Route: List all databases
	app.get '/api/dbs', dbPadRequest, (req, res, next) ->
				res.json req.databases

	app.get '/api/colls', dbPadRequest, (req, res, next) ->
				res.json req.collections

	# Route: List all collections for provided database
	app.get '/api/dbs/:db', dbPadRequest, (req, res, next) ->
				res.json req.collections[req.params.db]


	# Route: List all collections for provided database
	app.post '/api/dbs/:db', (req, res, next) ->
			cName = req.body.collection
			if cName? and cName.length
				if cName.match /^[a-zA-Z_][a-zA-Z0-9\._]*$/
					req.db.createCollection cName, (err, collection) ->
						if err
							req.session.error = 'Cannot create collection'
						dbCollRefresh(req.db, req.dbName)
						res.json 'Created ' + cName
				else
					res.json 'Invalid name'
			else
				res.json 'Provide a name'

	# Route: List documents in a particular collection
	app.get '/api/dbs/:db/:coll', (req, res, next) ->
			req.coll.find().toArray (err, result) ->
				res.json result

	# Route: List documents in a particular collection
	app.post '/api/dbs/:db/:collname', (req, res, next) ->
			req.
			db_this.collection(req.params.coll).find().toArray (err, result) ->
				res.json result

			