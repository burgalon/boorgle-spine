Spine = require('spine')
User = require('./user')
class FoundFriend extends User
  @extend Spine.Model.Ajax

  @configure 'FoundFriends'
  @extend Spine.Model.Ajax
  @ajaxPrefix: true
  @url: ->
    Spine.Model.host + "/found_friends"

module.exports = FoundFriend