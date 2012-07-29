Spine = require('spine')
$       = Spine.$
List    = require('spine/lib/list')

Authorization = require('authorization')

# Models
FoundFriend = require('models/found_friend')

# Controllers
UsersShow = require('controllers/users_show')
UsersList = require('controllers/users_list')

# Explore Tab - Found - Friend user detail
class FoundFriendShow extends UsersShow
  @configure FoundFriend
  tab: 'explore'

  back: ->
    @navigate('/found_friends', trans: 'left')

# Explore Tab - user list
class FoundFriendsList extends UsersList
  title: 'Explore'
  tab: 'explore'
  @configure FoundFriend, '/found_friends'
  elements: {}
  collection_types: FoundFriend.collection_types

  constructor: ->
    super

    # Set handles for sub-lists in the view
    for key in @collection_types
      @elements['.'+key] = key

    @html require('views/found_friends_list')(this)
    # Initialize list sub-views for each collection of users
    for key in @collection_types
      @[key+'_list'] = new List
            el: @[key],
            template: require('views/users/item')

  render: =>
    for key in @collection_types
      @[key+'_list'].render(FoundFriend[key].all())

# Explore Tab
class FoundFriends extends Spine.Controller
  tab: 'explore'

  constructor: ->
    super

    @list = new FoundFriendsList
    @show = new FoundFriendShow

    @routes
      '/found_friends/:id': (params) -> @show.active(params)
      '/found_friends': (params) -> @list.active(params)

module.exports = FoundFriends