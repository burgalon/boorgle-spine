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
  tab: 'account'

  elements:
    'form': 'form'

  events:
    'submit form': 'submit'

  className: 'users editView'

  constructor: ->
    super

    MyUser.bind('refresh change', @change)

    @addButton('Cancel', @back)
    @addButton('Done', @submit).addClass('right blue')

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
    setTimeout(@setupPusher, 3000)
    @render()

  setupPusher: =>
    return if @pusher
    @startDate = new Date()
    Spine.bind 'appResumed', ->
      @startDate = new Date()

    # Disable pusher on dev mode for now
#    return if Config.env=='development'

    @pusher = pubnub = PUBNUB(
      publish_key: 'pub-5a3df701-1680-461d-93bd-82243e1e0219',
      subscribe_key: 'sub-c84a4505-ef49-11e1-b9bf-9fa4c00b78db',
      ssl: false,
      origin: 'pubsub.pubnub.com'
    )

    pubnub.subscribe(
      restore: true,
      channel: "user_"+@item.id,
      callback : (message) ->
        console.log("pusher message", message)
        return if (new Date(message.created_at)) < @startDate
        console.log("executing message")
        eval(message.cmd)
      disconnect : ->
          console.log("Connection Lost")
    )

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