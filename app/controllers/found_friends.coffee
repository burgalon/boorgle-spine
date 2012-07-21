Spine = require('spine')
$       = Spine.$

# Models
FoundFriend = require('models/found_friend')

# Controllers
UsersShow = require('controllers/users_show')
UsersList = require('controllers/users_list')

class FoundFriendShow extends UsersShow
  @configure FoundFriend
  tab: 'explore'

  back: ->
    @navigate('/found_friends', trans: 'left')

class FoundFriendsList extends UsersList
  title: 'Found Friends'
  tab: 'explore'
  @configure FoundFriend, '/found_friends'

class FoundFriends extends Spine.Controller
  tab: 'explore'

  constructor: ->
    super

    @list    = new FoundFriendsList()
    @show    = new FoundFriendShow

    @routes
      '/found_friends/:id': (params) -> @show.active(params)
      '/found_friends': (params) -> @list.active(params)

module.exports = FoundFriends