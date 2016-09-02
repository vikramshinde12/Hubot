module.exports = (robot) ->
	employees = ['Angela', 'Manish', 'Poojan', 'Abhishek', 'Vikram', 'Prachi']
	robot.hear /random employee/i, (res) ->
		res.send res.random employees