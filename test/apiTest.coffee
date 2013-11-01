###
Import assertion modules.
###
chai = require 'chai'
should = chai.should()
expect = chai.expect
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
				expect(e).to.equal(null)
				done()



