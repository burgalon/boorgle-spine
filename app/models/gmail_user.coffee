Spine = require('spine')
App = require('index')
Authorization = require('authorization')

# Models
Model = require('./model')

# This is a user that was found from GMail, and is NOT a Boorgle user
# This model user can only be 'invited' but not directly 'added'
class GmailUser extends Model
  @configure 'GmailUser', 'name', 'picture', 'email'

  picture_url: ->
    ret = @picture
    ret+='?oauth_token='+ Authorization.getToken() if ret.match('localhost|boorgle')
    ret


module.exports = GmailUser