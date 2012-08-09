Spine = require('spine')
BasePanel = require('./base_panel')

Authorization = require('authorization')

# Model
MyUser = require('models/my_user')
# Models below needed for Pusher events
FoundFriend = require('models/found_friend')
Friend = require('models/friend')

# Controllers
PleaseLogin = require('controllers/please_login')
UsersShow = require('controllers/users_show')

class UserEditForm extends BasePanel
  title: 'Info'

  elements:
    'form': 'form'

  events:
    'submit form': 'submit'

  className: 'users editView'

  constructor: ->
    super

    MyUser.bind('refresh change', @change)
    @active @change

    @addButton('Cancel', @back)
    @addButton('Done', @submit).addClass('right')

    @active @render

  render: =>
    if @item
      @html require('views/users/form')(@item)
    else
      @html require('views/users/please_login')()

  submit: (e) ->
    e.preventDefault()
    Authorization.ajax(
      data: @form.serialize(),
      url: MyUser.url(),
      type: 'PUT',
      contentType: 'application/x-www-form-urlencoded; charset=UTF-8'
    ).done( (data) =>
      MyUser.refresh(data)
    )
    @navigate('/user/edit/show', trans: 'left')

  back: ->
    @navigate('/user/edit/show', trans: 'left')

  deactivate: ->
    super
    @form.blur()

  change: =>
    @item = MyUser.first()
    @setupPusher()
    @render()

  setupPusher: ->
    return if @pusher || !@item

    # Disable pusher on dev mode for now
    return if Config.env!='production'
    # Enable pusher logging - don't include this in production
    if Config.env!='production'
      Pusher.log = (message) ->
        window.console.log message  if window.console and window.console.log

      # Flash fallback logging - don't include this in production
      WEB_SOCKET_DEBUG = true

    @pusher = new Pusher("59ef2ea7851fc5a12a57")
    channel = @pusher.subscribe("user_"+@item.id)
    channel.bind "rpc", (data) ->
      eval(data.cmd)


class MyUserShow extends UsersShow
  title: 'Info'
  tab: 'account'

  @configure MyUser

  add_buttons: ->
    @addButton('Edit', @back)
    @addButton('Log Out', @logout).addClass('right')

  back: ->
    @navigate('/user/edit', trans: 'right')

  logout: ->
    Authorization.logout()

  change: (params) =>
    super(id: 'my-user')

class UserEdit extends Spine.Controller
  constructor: ->
    super

    if Authorization.is_loggedin()
      @form = new UserEditForm
      @show = new MyUserShow
    else
      @form = new PleaseLogin('Info', 'account')
      @show = new PleaseLogin('Info', 'account')

    @routes
      '/user/edit/show': (params) -> @show.active(params)
      '/user/edit': (params) -> @form.active(params)

module.exports = UserEdit