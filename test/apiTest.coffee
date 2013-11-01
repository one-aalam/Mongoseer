###
Import assertion modules.
###
chai = require 'chai'
should = chai.should()
superagent = require 'superagent'
req = superagent.agent()
### Test Server: Started by Grunt ###
path = 'http://localhost:3000/api' 
###
Describe tests
###

describe 'MongoSeer REST API', ->

	it 'GET /api/dbs should return all local databases', (done) ->
			req.get(path + '/dbs').end (e,res) ->
				should.not.exist(e)
				should.exist(res)
				res.should.be.an('object')
				res.status.should.equal(200)
				done()



