module.exports = (robot) ->
	robot.respond /square (.*)/i, (res) ->
		input = res.match[1]
		integer = Number(input)
		if String(integer) is "NaN"
		  res.send "That is not a number!"
		else
		  square = integer * integer
		  res.send "The square of #{integer} is #{square}"