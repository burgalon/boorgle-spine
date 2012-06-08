require('lib/setup')

Spine   = require('spine')
{Stage} = require('spine.mobile')

# Models
FoundFriend = require('models/found_friend')
MyUser = require('models/my_user')

# Controllers
FoundFriends = require('controllers/found_friends')
UserEdit = require('controllers/user_edit')

Spine.Model.host = "http://localhost:3000/api/v1"

class App extends Stage.Global
  constructor: ->
    @log 'App::constructor super'
    super

    @check_for_oauth_token()

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

  check_for_oauth_token: ->
    @log 'App::check_for_oauth_token'
    matches = window.location.hash.match('access_token\=([^&]+)')
    @log 'App::check_for_oauth_token found!'
    localStorage['oauth_token'] = matches[1] if matches

  @oauth_token: ->
    localStorage['oauth_token']

module.exports = App