# Description:
#  This script will create channel in the slack
#
# Configuration:
#   process.env.SLACK_API_TOKEN - xoxp-63552391444-63562581831-68847793700-477be5d0f3
#
# Commands:
#   hubot create channel <channel_name> -- This will create channel in slack
# Notes:
#   None.
#
# Author:

token = process.env.SLACK_API_TOKEN

module.exports = (robot) ->
  robot.hear /create channel (.*)/i, (msg) ->
#    token="xoxp-63552391444-63562581831-68847793700-477be5d0f3"
    name = msg.match[1]
    angelalukic = 'U26A90P97'
    chandwanik = 'U24SL1PD3'
    hubot = 'U24E9V6SZ'
    naga = 'U24SA77EY'
    poojanr = 'U24CPL22X'
    prachi = 'U24EAQ3QD'
    vikram = 'U24E8SM6H'
    vaibhavlp = 'U24FHP5M2'
    
    hubot = 'U24E9V6SZ'
    kajal = 'U1VGKABP1'
    naga1 =  'U1W01582U'
    vik =   'U1VGJH3QF'
    create_channel msg, token, name, (res) ->
      json = JSON.parse(res)
      if res.match(/created/)
        msg.send "Channel Created #{name}\n id: #{json.channel.id}"
        channel_id = json.channel.id
        invite_people msg, token, channel_id, angelalukic, (res) -> 
          if res.match(/user_not_found/)
            msg.send "angela not invited"
          else
            msg.send "Invited angelalukic in channel #{name}"
        invite_people msg, token, channel_id, naga, (res) -> 
          msg.send "Invited naga in channel #{name}"
        invite_people msg, token, channel_id, chandwanik, (res) -> 
          msg.send "Invited chandwanik in channel #{name}"
        invite_people msg, token, channel_id, poojanr, (res) -> 
          msg.send "Invited poojanr in channel #{name}"
        invite_people msg, token, channel_id, prachi, (res) -> 
          msg.send "Invited prachi in channel #{name}"
        invite_people msg, token, channel_id, vikram, (res) -> 
          msg.send "Invited vikram in channel #{name}"
        invite_people msg, token, channel_id, vaibhavlp, (res) -> 
          msg.send "Invited vaibhavlp invited in channel #{name}"
        invite_people msg, token, channel_id, hubot, (res) -> 
          msg.send "Invited hubot invited in channel #{name}"
          console.log res
        invite_people msg, token, channel_id, naga1, (res) -> 
          msg.send "Invited naga1 invited in channel #{name}"
        invite_people msg, token, channel_id, kajal, (res) -> 
          msg.send "Invited kajal invited in channel #{name}"
        invite_people msg, token, channel_id, vik, (res) -> 
          msg.send "Invited vik invited in channel #{name}"
          console.log res  

      if res.match(/name_taken/)
        msg.send "This channel is already created"

  create_channel = (msg, token, name, cb) ->
    msg.http("https://slack.com/api/channels.create?token=#{token}&name=#{name}")
      .header('accept', '*/*')
      .header('User-Agent', "Hubot/#{@version}")
      .header('Content-Type', 'text/plain')
      .get() (err, res, body) ->
        cb body


  invite_people = (msg, token, channel_id, user, cb) ->
    user1='U1W01582U'
    msg.http("https://slack.com/api/channels.invite?token=#{token}&channel=#{channel_id}&user=#{user}&pretty=1")
      .header('accept', '*/*')
      .header('User-Agent', "Hubot/#{@version}")
      .header('Content-Type', 'text/plain')
      .get() (err, res, body) ->
        cb body