module.exports = (robot) ->
	robot.hear /what is (.*)'s last name/i, (res) ->
		name = res.match[1]
		if name is "Angela"
			res.reply "#{name}'s last name is Lukic!"
		else
			res.reply "I don't know what #{name}'s last name is :("