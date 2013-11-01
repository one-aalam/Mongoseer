module.exports = (app) ->
	require('./development')(app)
	require('./production')(app)
