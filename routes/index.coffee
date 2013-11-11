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

# Helpers

# Check if provided name/string is valid
validName = (name) ->
	name.match /^[a-zA-Z_][a-zA-Z0-9\._]*$/

# Generate proper document ID
docId     = (id) ->
	conn.bson_serializer.ObjectID.createFromHexString(id)




db.open (err, dbLocal) ->
	if err then throw err
	conn = dbLocal

	dbLocal.admin (e, dbAdmin) ->
		admin = dbAdmin
		dbRefresh(dbAdmin)
				

module.exports = (app) ->

	'use strict'

	###
	Parameters: Request padding
	###

	# Stuff database and database name in its presence
	app.param 'db', (req, res, next, db) ->
		#if databases[db]? then req.dbName = db else req.session.error = 'DB missing'
		req.dbName = db
		if connections[db]?
  			req.db = connections[db]
		else
  			connection[db] = conn.db(db)
  			req.db = connections[db]
		next()

	# Stuff collection and its name in its presence
	app.param 'coll', (req, res, next, collName) ->
		if collections[req.dbName]?
			req.collName = collName
		else 
			req.session.error = 'Coll missing'

		req.db.collection collName, (err, coll) ->
			if err or !coll
				console.log 'Collection error'
			else
				req.collection = coll
		next()

	# Route: '/' Available for client-side MVC
	app.get '/', (req, res, next) ->
		res.render 'index',{title:'MongoSeer - Tiny MongoDB client!'}

	###
	Connection: Exposed methods (General purpose)
	###

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

	###
	Database: Exposed methods
	###

	# Route: List all collections for provided database
	app.get '/api/dbs/:db', dbPadRequest, (req, res, next) ->
				res.json req.collections[req.params.db]

	###
	Collection: Exposed methods
	###

	# Route: Create a new collection
	app.post '/api/dbs/:db', (req, res, next) ->
			cName = req.body.collection
			if cName? and cName.length
				if validName(cName)
					req.db.createCollection cName, (err, collection) ->
						if err then next(err)
						dbCollRefresh(req.db, req.dbName)
						res.json "Created collection '#{cName}' in '#{req.dbName}'"
				else
					res.json 'Invalid name'
			else
				res.json 'Provide a name'

	# Route: List documents in a particular collection
	app.get '/api/dbs/:db/:coll', (req, res, next) ->
			req.collection.find().toArray (err, result) ->
				res.json result

	# Route: Rename a collection 
	app.post '/api/dbs/:db/:coll/rename', (req, res, next) ->
			cName = req.body.collection
			if cName? and cName.length and validName(cName)
				req.collection.rename cName, (err, result) ->
					dbCollRefresh(req.db, req.dbName)
					#if err then res.json err
					res.json result
			else
				res.json 'Notning changes, Nothing changed!'

	# Route: Delete a collection
	app.del '/api/dbs/:db/:coll', (req, res, next) ->
			req.collection.drop (err, result) ->
				dbCollRefresh(req.db, req.dbName)
				res.json "Deleted '#{req.collName}'"

	###
	Documents: Exposed methods
	###

	# Route: Get document from a particular collection
	app.get '/api/dbs/:db/:coll/:id', (req, res, next) ->
			id = req.db.bson_serializer.ObjectID.createFromHexString(req.param('id').toString())
			req.collection.findOne {_id: id}, (err, result) ->
				if err then next(err) # -> Error handling middleware
				res.json result

	# Route: Post documents to a particular collection
	app.post '/api/dbs/:db/:coll', (req, res, next) ->
			doc = req.body
			req.collection.insert doc, (err, result) ->
				if err then next(err) # -> Error handling middleware
				res.json result

	# Route: Update a document in provided collection
	app.put '/api/dbs/:db/:coll/:id', (req, res, next) ->
			id = req.db.bson_serializer.ObjectID.createFromHexString(req.param('id').toString())
			doc = req.body
			req.collection.update {_id: id}, doc, {strict: true}, (err, result) ->
				if err then next(err)
				res.json if result is 1 then "Updated collection with #{id}" else "Couldn't update!"

	# Route: Remove a document with provided id
	app.del '/api/dbs/:db/:coll/:id', (req, res, next) ->
			id = req.db.bson_serializer.ObjectID.createFromHexString(req.param('id').toString())
			req.collection.remove {_id: id}, (err, result) ->
				if err then next(err)
				res.json if result is 1 then "Deleted collection with #{id}" else "Undeletable!"

			