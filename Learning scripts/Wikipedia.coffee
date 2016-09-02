module.exports = (robot) ->
	robot.hear /wikipedia/i, (msg) ->
		msg.http('https://en.wikipedia.org/w/api.php?format=json&action=query&prop=extracts&exintro=&explaintext=&titles=Mastek')
		.get() (err, res, body) ->
			excerpt = JSON.parse(body)
			
			if err
				msg.send "An error has occured."
				
			else
				msg.send "#{body}"