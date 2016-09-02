module.exports = (robot) ->
	monster = "Rathian"
	element = ["Fire"]
	blight = ["Poison", "Fireblight"]
	weakelement = ["Dragon", "Thunder"]
	weakailment = ["Paralysis", "Blast"]
	
	# HuBot, give me an overview of the Rathian.
	robot.respond /overview Rathian/i, (res) ->
		res.send "The #{monster} deals #{element} damage. It inflicts #{blight}."

    # HuBot, what is the Rathian weak to?
	robot.respond /weaknesses Rathian/i, (res) ->
		res.send "The #{monster} is weak to #{weakelement}."
		res.send "It is also vulnerable to #{weakailment}."
		