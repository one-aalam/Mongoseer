module.exports = (app) ->
	app.get '/', (req, res, next) ->
		res.render 'index',{title:'Express'}

	app.get '/api', (req, res, next) ->
		res.json 'API call'