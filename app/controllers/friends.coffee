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

  back: ->
    @navigate('/friends', trans: 'left')

class FriendsList extends UsersList
  title: 'Synched'
  @configure Friend, '/friends'

class Friends extends Spine.Controller
  constructor: ->
    super

    if Authorization.is_loggedin()
      @list = new FriendsList
      @show = new FriendShow
    else
      @list = new PleaseLogin('Synced')
      @show = new PleaseLogin('Info')

    @routes
      '/friends/:id': (params) -> @show.active(params)
      '/friends': (params) -> @list.active(params)

module.exports = Friends