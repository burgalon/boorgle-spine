Spine = require('spine')
BasePanel = require('./base_panel')

Authorization = require('authorization')

# Model
MyUser = require('models/my_user')
# Models below needed for Pusher events
FoundFriend = require('models/found_friend')
Friend = require('models/friend')

# Controllers
UsersShow = require('controllers/users_show')

class About extends BasePanel
  title: 'About'
  tab: 'account'
  className: 'about'

  constructor: ->
    super
    @addButton('Back', -> @navigate '/please_login', trans: 'left')
    @render()

  render: =>
    @html require('views/users/about')

class Login extends BasePanel
  title: 'Log In'
  tab: 'account'

  elements:
    'form': 'form'

  events:
    'submit form': 'submit'
    'change input': 'checkValidity'
    'keyup input': 'checkValidity'
    'tap .forgot-password': 'forgotPassword'

  className: 'users editView login'

  constructor: ->
    super

    @addButton('Cancel', -> @navigate '/please_login', trans: 'left')
    @doneButton = @addButton('Log In', @submit).addClass('right blue')

    @render()

  render: =>
    @html require('views/users/login')
    @checkValidity()

  submit: (e) ->
    #    return @log 'UserEditForm.submit - invalid form' if @doneButton.attr('disabled')
    e.preventDefault()
    basic_auth = @form.serializeArray().map((el) -> el.value)
    basic_auth = basic_auth.join ':'
    basic_auth = Base64.encode basic_auth
    Authorization.ajax(
      data: "commit=true&client_id=#{Config.clientId}&response_type=token&redirect_uri=#{Config.oauthRedirectUri}",
      headers: {"Authorization": "Basic #{basic_auth}"}
      url: Config.oauthEndpoint + 'authorize.json',
      type: 'POST',
      contentType: 'application/x-www-form-urlencoded; charset=UTF-8'
    ).done( (data) =>
      Authorization.saveToken(data.access_token)
      FoundFriend.fetch()
      MyUser.fetch()
      Friend.fetch()
      $('body').removeClass('loggedout')
      @navigate '/found_friends'
    ).fail ( (xhr) =>
      if xhr.status is 401
        msg = "Password incorrect"
      else
        msg = "Network Error: #{xhr.statusText} (#{xhr.status}). #{xhr.responseText}"
      Spine.trigger 'notify', msg: msg
    )

  checkValidity: ->
    if @form[0].checkValidity()
      @doneButton.removeClass 'disabled'
    else
      @doneButton.addClass 'disabled'

  forgotPassword: ->
    window.open Config.host.replace('/api/v1', '') + '/accounts/password/new'

class UserEditForm extends BasePanel
  title: 'Info'
  tab: 'account'

  elements:
    'form': 'form'

  events:
    'submit form': 'submit'
    'change input': 'checkValidity'
    'keyup input': 'checkValidity'

  className: 'users editView'

  constructor: ->
    super
    @item = new MyUser()
    MyUser.bind('refresh change', @change)

    @addButton('Cancel', @back)
    @doneButton = @addButton('Done', @submit).addClass('right blue')

    @render()

  render: =>
    @html require('views/users/form')(@item)
    @checkValidity()

  submit: (e) ->
    e.preventDefault()
    Authorization.ajax(
      data: @form.serialize() + "&client_id=#{Config.clientId}&response_type=token&redirect_uri=#{Config.oauthRedirectUri}",
      url: MyUser.url(),
      type: if @item.isNew() then 'POST' else 'PUT',
      contentType: 'application/x-www-form-urlencoded; charset=UTF-8'
    ).done( (data) =>
      # Implies signup
      if data.access_token
        Authorization.saveToken(data.access_token)
        MyUser.refresh(data.user)
        $('body').removeClass('loggedout')
        @navigate '/found_friends'
      else
        @navigate '/user/edit/show'
    ).fail ( (data) =>
    )

  checkValidity: ->
    if @form[0].checkValidity()
      @doneButton.removeClass 'disabled'
    else
      @doneButton.addClass 'disabled'

  back: ->
    if @item.id
      @navigate('/user/edit/show', trans: 'left')
    else
      @navigate('/please_login', trans: 'left')

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
    @navigate '/please_login'
    Authorization.logout()

  change: (params) =>
    super(id: 'my-user')

class UserEdit extends Spine.Controller
  constructor: ->
    super

    @form = new UserEditForm
    @show = new MyUserShow
    @login = new Login
    @about = new About

    @routes
      '/user/edit/show': (params) -> @show.active(params)
      '/user/edit': (params) -> @form.active(params)
      '/user/login': (params) -> @login.active(params)
      '/about': (params) -> @about.active(params)

module.exports = UserEdit