Spine = require('spine')
User = require('./user')
class Friend extends User

  @configure 'Friend'
  @extend Spine.Model.Ajax
  @url: ->
    Spine.Model.host + "/friends"

module.exports = Friend