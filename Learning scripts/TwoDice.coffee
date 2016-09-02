# This will roll two different random numbers

module.exports = (robot) ->
	numbers = ['1', '2', '3', '4', '5', '6']
	
	robot.respond /roll dice/i, (res) ->
		
		dice1 = res.random numbers
		dice2 = res.random numbers
		
		res.send "I rolled #{dice1} and #{dice2}"
		
		if dice1 is '6' and dice2 is '6'
			
			res.send "I rolled two sixes! Super Lucky!"
			
		else if dice1 is '1' and dice2 is '1'
				
			res.send "Snake Eyes :("
		
		else if dice1 is dice2

			res.send "I rolled two of the same number! I get to roll again!"
			