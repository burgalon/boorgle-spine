Spine = require('spine')
{Panel} = require('spine.mobile')
$       = Spine.$

# Models
FoundFriend = require('models/found_friend')

# Controllers
UsersShow = require('controllers/users_show')

class UsersList extends Panel
  events:
    'tap .item': 'click'

  title: 'Found Friends'

  className: 'users list listView'

  constructor: ->
    super

    FoundFriend.bind('refresh change', @render)

  render: =>
    items = FoundFriend.all()
    @html require('views/users/item')(items)

  click: (e) ->
    item = $(e.target).item()
    @log 'UsersList::click ', item, item.id
    @navigate('/users', item.id, trans: 'right')

  add: ->
    @navigate('/users/create', trans: 'right')

class FoundFriendShow extends UsersShow
  @configure FoundFriend

  back: ->
    @navigate('/found_friends', trans: 'left')

class FoundFriends extends Spine.Controller
  constructor: ->
    super

    @list    = new UsersList
    @show    = new FoundFriendShow

    @routes
      '/users/:id': (params) -> @show.active(params)
      '/found_friends': (params) -> @list.active(params)

module.exports = FoundFriends