# Description:
#   This script receives pages in the formats
#        /usr/bin/curl -d host="$HOSTALIAS$" -d output="$SERVICEOUTPUT$" -d description="$SERVICEDESC$" -d type=service -d notificationtype="$NOTIFICATIONTYPE$ -d state="$SERVICESTATE$" $CONTACTADDRESS1$
#        /usr/bin/curl -d host="$HOSTNAME$" -d output="$HOSTOUTPUT$" -d type=host -d notificationtype="$NOTIFICATIONTYPE$" -d state="$HOSTSTATE$" $CONTACTADDRESS1$
#
#   Based on a gist by oremj (https://gist.github.com/oremj/3702073)
#
# Configuration:
#   HUBOT_NAGIOS_URL1 - https://<user>:<password>@nagios.example.com/cgi-bin/nagios3
#
# Commands:
#   hubot nagios hosts [<all|up|down|unreachable>] - view problem hosts
#   hubot nagios host status <host> - Check the status of the perticular host
#   hubot nagios services [<critical|warning|unknown>] - view non-OK service issues
#   hubot nagios service status <host>>:<service> - Check the status of the perticular service
#   hubot nagios ack <host>:<service> <descr> - acknowledge alert
#   hubot nagios mute <host>:<service> <minutes> - delay the next service notification
#   hubot nagios recheck <host>:<service> - force a recheck of a service
#   hubot nagios all_alerts_off - useful in emergencies. warning: disables all alerts, not just bot alerts
#   hubot nagios all_alerts_on - turn alerts back on


moment      = require 'moment'
Select      = require("soupselect").select
HtmlParser  = require 'htmlparser'
JSDom       = require 'jsdom'
Entities    = require('html-entities').AllHtmlEntities;

nagios_url = process.env.HUBOT_NAGIOS_URL1

module.exports = (robot) ->

  robot.router.post '/hubot/nagios/:room', (req, res) ->
    room = req.params.room
    host = req.body.host
    output = req.body.output
    state = req.body.state
    notificationtype = req.body.notificationtype

    if req.body.type =d= 'host'
      robot.messageRoom "#{room}", "nagios #{notificationtype}: #{host} is #{output}"
    else
      service = req.body.description
      robot.messageRoom "#{room}", "nagios #{notificationtype}: #{host}:#{service} is #{state}: #{output}"

    res.writeHead 204, { 'Content-Length': 0 }
    res.end()

  robot.respond /nagios all_alerts_on/i, (msg) ->
    call = "cmd.cgi"
    data = "cmd_typ=12&cmd_mod=2"
    nagios_post msg, call, data, (res) ->
      if res.match(/Your command request was successfully submitted to Nagios for processing/)
        msg.send "Ok, alerts back on"

  robot.respond /nagios (all_alerts_off|stfu|shut up)/i, (msg) ->
    call = "cmd.cgi"
    data = "cmd_typ=11&cmd_mod=2"
    nagios_post msg, call, data, (res) ->
      if res.match(/Your command request was successfully submitted to Nagios for processing/)
        msg.send "Ok, all alerts off. (this disables ALL alerts, not just mine.)"

  robot.respond /nagios mute (.*):(.*) (\d+)/i, (msg) ->
    host = msg.match[1]
    service = msg.match[2]
    minutes = msg.match[3] || 30
    call = "cmd.cgi"
    data = "cmd_typ=9&cmd_mod=2&&host=#{host}&service=#{service}&not_dly=#{minutes}"
    nagios_post msg, call, data, (res) ->
      if res.match(/Your command request was successfully submitted to Nagios for processing/)
        msg.send "Muting #{host}:#{service} for #{minutes}m "

  robot.respond /nagios ack (.*):(.*) (.*)/i, (msg) ->
    host = msg.match[1]
    service = msg.match[2]
    message = msg.match[3] || " "
    call = "cmd.cgi"
    data = "cmd_typ=34&host=#{host}&service=#{service}&cmd_mod=2&sticky_ack=on&com_author=#{msg.envelope.user.name}&send_notification=on&com_data=#{encodeURIComponent(message)}"
    console.log data
    nagios_post msg, call, data, (res) ->
      if res.match(/successfully submitted to Nagios/)
        msg.send "Your acknowledgement was received by nagios"
      else
        msg.send "that didn't work.  Maybe a typo?"  

  robot.respond /nagios recheck (.*):(.*)/i, (msg) ->
    host = msg.match[1]
    service = msg.match[2]
    call = "cmd.cgi"
    start_time = moment().format("YYYY-MM-DD+HH:mm:ss")
    data = "cmd_typ=7&cmd_mod=2&host=#{host}&service=#{service}&force_check=on&start_time=#{start_time}"
    console.log data
    nagios_post msg, call, data, (res) ->
      if res.match(/successfully submitted/)
        msg.send "Scheduled to recheck #{host}:#{service} at #{start_time}"
      else
        msg.send "not submitted"

  robot.respond /nagios hosts (.*)/i, (msg) ->
    words = msg.match[1]
    input = words.split(' ');
    if input[0].match(/(all|ALL)/i)
      inp='UP|DOWN|UNREACHABLE'
    else
      inp=input[0]
    status = (inp || ".*").toUpperCase()
    switch status
      when 'UP' then sts = '2'
      when 'DOWN'  then sts = '4'
      when 'UNREACHABLE'  then sts = '8'
    call = "status.cgi"
    data = "hostgroup=all&style=hostdetail"
    if input[0].match(/(all|ALL)/i)
      info = "#{nagios_url}/#{call}?#{data}"
    else
      info = "#{nagios_url}/#{call}?#{data}&hoststatustypes=#{sts}"
    nagios_post msg, call, data, (html) ->
      host_parse html, status, (res) -> 
        if res.length > 0
          res = "#{status} hosts: #{info}\n Host            Status          Duration \n" + res
          msg.send res
        else
          msg.send "I did not find any hosts in '#{status}' state"

  robot.respond /nagios services (NULL|(.*))/i, (msg) ->
    words = msg.match[1]
    input = words.split(' ');
    if input.length < 1 || !input[0].match(/(critical|warning|unknown)/i)
      msg.send "Usage: nagios #{cmd} <critical|warning|unknown>"
    else
      status = (input[0] || ".*").toUpperCase()
      switch status
        when 'CRITICAL' then sts = '16'
        when 'WARNING'  then sts = '4'
        when 'UNKNOWN'  then sts = '8'
      call = "status.cgi"
      data = "host=all&style=detail&servicestatustypes=#{sts}&limit=0"
      info = "#{nagios_url}/#{call}?#{data}"
      nagios_post msg, call, data, (html) ->
        host_service_parse html, 'services', '.*', (res) -> 
          if res.length > 0
            res = "#{status} services: #{info}\n" + res
            msg.send res
          else
            msg.send "I did not find any services in '#{status}' state"

  robot.respond /nagios host status (.*)/i, (msg) ->
    host = msg.match[1]
    call = "extinfo.cgi"
    data = "type=1&host=#{host}"
    nagios_post msg, call, data, (res) ->
      if res.match(/hostUP/)
        msg.send "Host status of #{host} is UP"
      if res.match(/hostDOWN/)
        msg.send "Host status of #{host} is DOWN"
  
  robot.respond /nagios service status (.*):(.*)/i, (msg) ->
    host = msg.match[1]
    service = msg.match[2]
    call = "extinfo.cgi"
    data = "type=2&host=#{host}&service=#{service}"
    nagios_post msg, call, data, (res) ->
      if res.match(/serviceOK/)
        msg.send "Service status of #{host}: #{service} is OK"
      if res.match(/serviceCRITICAL/)
        msg.send "Service status of #{host}: #{service} is CRITICAL"
      if res.match(/serviceWARNING/)
        msg.send "Service status of #{host}: #{service} is WARNING"

  nagios_post = (msg, call, data, cb) ->
    msg.http("#{nagios_url}/#{call}")
      .header('accept', '*/*')
      .header('User-Agent', "Hubot/#{@version}")
      .post(data) (err, res, body) ->
        cb body

  host_parse = (html, match, cb) ->
    entities = new Entities()
    handler = new HtmlParser.DefaultHandler()
    parser  = new HtmlParser.Parser handler
    parser.parseComplete html

    results = (Select handler.dom, "td")
    output = ""
    for item in results
      if item['attribs'] && item['attribs']['class'] && item['attribs']['class'].match(/^status/)
        for child in item['children']
          if child['raw'].match(/&host=/)
            buffer = "`"+child['children'][0]['raw'] + "` "
          if child['raw'].match(/^(UP|DOWN|UNREACHABLE)$/)
            status = child['raw']
            buffer += "*#{status}* "
            mark = 0
          if mark == 2
              buffer += "`"+child['raw'] + "`\n"
              if status.match(match) then output += buffer
      mark += 1
    cb output

host_service_parse = (html, type, match, cb) ->
  entities = new Entities()
  handler = new HtmlParser.DefaultHandler()
  parser  = new HtmlParser.Parser handler
  parser.parseComplete html

  results = (Select handler.dom, "td")
  output = ""
  host = ""
  for item in results
    if item['attribs'] && item['attribs']['class'] && item['attribs']['class'].match(/^status/)
      for child in item['children']
        if type == 'services' && child['attribs'] && 
           child['attribs']['href']  &&
           child['attribs']['href'].match(/1&host=/)
          host = "*#{child['children'][0]['raw']}*"
        if child['raw'].match(/&service=/)
          service = child['children'][0]['raw']
          buffer = "#{host} `#{service}` "
        if child['raw'].match(/^(OK|WARNING|CRITICAL|UNKNOWN)$/)
          buffer += "*#{child['raw']}* "
          mark = 0
        switch mark
          when 2, 3 then buffer += "`"+child['raw'] + "` "
          when 4 
            buffer += "\"" + entities.decode(child['raw']) + "\"\n"
            if service.match(match) then output += buffer
    mark += 1
  cb output