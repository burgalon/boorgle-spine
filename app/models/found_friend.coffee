Spine = require('spine')
User = require('./user')
class FoundFriend extends User

  @configure 'FoundFriends'
  @extend Spine.Model.Ajax
  @url: ->
    Spine.Model.host + "/found_friends"

module.exports = FoundFriend