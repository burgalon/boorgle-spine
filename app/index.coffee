require('lib/setup')

Spine   = require('spine')
{Stage} = require('spine.mobile')

# Models
FoundFriend = require('models/found_friend')
MyUser = require('models/my_user')

# Controllers
FoundFriends = require('controllers/found_friends')
UserEdit = require('controllers/user_edit')

class App extends Stage.Global
  clientId: 'boorgle-iphone'
  oauthEndPoint: "http://localhost:3000/oauth/authorize?client_id=#{@::clientId}&response_type=token&redirect_uri=#{window.location}"

  constructor: ->
    @log 'App::constructor super'
    super

    @token = @getToken()
    @log "Token ", @token
    unless @token
      document.location = @oauthEndPoint
      return

    Spine.Model.host = "http://localhost:3000/api/v1"
    Spine.Ajax.defaults.headers['Authorization'] = @token

    # Models
    FoundFriend.fetch()
    MyUser.fetch()

    # Controllers
    @log 'App::constructor Controllers'
    @user_edit = new UserEdit
    @found_friends = new FoundFriends

    # General initializations
    @log 'App::constructor General initializations'

    Spine.Route.setup()#shim:true)
#    @navigate '/found_friends'
    @navigate '/user/edit'


  getToken: ->
    document.location.hash.match(/access_token=(\w+)/)?[1]

module.exports = App