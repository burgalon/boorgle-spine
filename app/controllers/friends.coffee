Spine = require('spine')
$       = Spine.$

Authorization = require('authorization')

# Models
Friend = require('models/friend')

# Controllers
PleaseLogin = require('controllers/please_login')
UsersShow = require('controllers/users_show')
UsersList = require('controllers/users_list')

class FriendShow extends UsersShow
  @configure Friend
  tab: 'contacts'

  back: ->
    @navigate('/friends', trans: 'left')

class FriendsList extends UsersList
  title: 'Contacts'
  tab: 'contacts'
  className: 'users list listView friends_list'
  @configure Friend, '/friends'

  render: =>
    items = @constructor.model_class.all()
    if items.length
      @html require('views/users/item')(items)
      @el.removeClass('empty')
    else
      @html require('views/friends_list')()
      @el.addClass('empty')


class Friends extends Spine.Controller
  tab: 'contacts'

  constructor: ->
    super

    if Authorization.is_loggedin()
      @list = new FriendsList
      @show = new FriendShow
    else
      @list = new PleaseLogin('Contacts', 'contacts')
      @show = new PleaseLogin('Contacts', 'contacts')

    @routes
      '/friends/:id': (params) -> @show.active(params)
      '/friends': (params) -> @list.active(params)

module.exports = Friends