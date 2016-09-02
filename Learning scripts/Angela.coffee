module.exports = (robot) ->
	robot.hear /what is lukic's first name?/i, (res) ->
		res.send "Lukic's first name is Angela!"
