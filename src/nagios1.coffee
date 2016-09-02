room = process.env.HUBOT_NAGIOS_EVENT_NOTIFIER_ROOM

module.exports = (robot) ->
  robot.router.post '/hubot/nagios1/host', (request, response) ->
    host = request.body.host
    hostOutput = request.body.hostoutput
    notificationType = request.body.notificationtype
#    room = "C1VGJH5DM"
#    robot.messageRoom room, "test-host"
    announceNagiosHostMessage host, hostOutput, notificationType, (msg) ->
      robot.messageRoom room, msg
    response.end ""
  
  robot.router.post '/hubot/nagios1/service', (request, response) ->
    host = request.body.host
    serviceOutput = request.body.serviceoutput
    notificationType = request.body.notificationtype
    serviceDescription = request.body.servicedescription
    serviceState = request.body.servicestate
#    robot.messageRoom room, "test-service"

    announceNagiosServiceMessage host, notificationType, serviceDescription, serviceState, serviceOutput, (msg) ->
      robot.messageRoom room, msg

    response.end ""

announceNagiosHostMessage = (host, hostOutput, notificationType, cb) ->
  cb "nagios #{notificationType}: #{host} is #{hostOutput}"

announceNagiosServiceMessage = (host, notificationType, serviceDescription, serviceState, serviceOutput, cb) ->
  cb "nagios #{notificationType}: #{host}:#{serviceDescription} is #{serviceState}: #{serviceOutput}"