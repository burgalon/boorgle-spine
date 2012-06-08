Spine = require('spine')
App = require('index')

# Models
User = require('./user')
OauthBase = require('./oauth_base')

class MyUser extends User
  @configure 'MyUser'
  @url: ->
    Spine.Model.host + "/user"

  # For UsersShow which uses find with id=undefined
  @find: ->
    @first()

  # TO-DO: to be continued .... fix OauthBase
  @fetch: ->
    return [] unless localStorage['oauth_token']
    console.log "FETCH ", localStorage['oauth_token']
    super(headers: {'Authorization': localStorage['oauth_token']})

module.exports = MyUser