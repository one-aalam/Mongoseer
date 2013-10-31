app = require './app'

require('http').createServer(app).listen app.get('port'), ->
	console.log 'Express (' + app.get('env') + ') server listening on port ' + app.get('port')

