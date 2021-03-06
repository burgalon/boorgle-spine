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
Settings = require('controllers/settings')

class Login extends BasePanel
  title: 'Log In'
  tab: 'account'

  elements:
    'form': 'form'
    '.password': 'password'

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
    return @alert 'Please fill form' unless @form[0].checkValidity()

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
      Spine.trigger 'login'
      # When signing up, cancel button is available to go back to the /please_login
      # but once email is entered we are in 'steps' mode that cannot be canceled
      @cancelButton.remove() if @cancelButton
    ).fail ( (xhr) =>
      @log 'login fail', arguments
      if xhr.status is 401
        msg = "Could not find user/password"
      else
        msg = "Network Error: #{xhr.statusText} (#{xhr.status}). #{xhr.responseText}"
      @alert msg
    )

  alert: (msg) ->
    @hideKeyboard()
    Spine.trigger 'notify', msg: msg, class: 'warn'

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
    'focus .input-phone': 'onFocusPhone'
    'blur .input-phone': 'onBlurPhone'
    'change .input-phone': 'onChangePhone'
    'keyup .input-phone': 'onChangePhone'

  className: 'users editView'
  isSteps: true

  constructor: ->
    super
    @item = new MyUser()
    MyUser.bind('refresh change', @change)

    @doneButton = @addButton('Done', @submit).addClass('right blue')
    @cancelButton = @addButton('Cancel', @back) unless Authorization.is_loggedin()

    # When activating tab, render the view in order to revert any canceled former editing
    @active => @render()

    @render()

  render: =>
    return unless @isActive()
    if !@item.email
      @html require('views/users/form_email')(@item)
    else if !@item.first_name || !@item.last_name
      @html require('views/users/form_name')(@item)
    else if !@item.phones.length
      @html require('views/users/form_phone')(@item)
    else if !@item.zipcode
      @html require('views/users/form_address')(@item)
    else
      Spine.trigger 'login' if @isSteps
      @isSteps = false
      @html require('views/users/form')(@item)

    if @isSteps
      @log 'Focusing', $($('input', @form))
      $($('input', @form)[0]).focus()
      @doneButton.text('Next')
    @checkValidity()

  submit: (e) ->
    e.preventDefault()

    unless @form[0].checkValidity()
      el = $($('input:invalid', @form)[0])
      el.focus()
      @alert el.attr('placeholder')
      return false

    Authorization.ajax(
      data: @form.serialize() + "&client_id=#{Config.clientId}&response_type=token&redirect_uri=#{Config.oauthRedirectUri}",
      url: MyUser.url(),
      type: if @item.isNew() then 'POST' else 'PUT',
      contentType: 'application/x-www-form-urlencoded; charset=UTF-8'
    ).done( (data) =>
      $('body').removeClass('loggedout') unless @item.validate()
      # Implies signup
      if data.access_token
        Authorization.saveToken(data.access_token)
        @navigate(if @isSteps then '/user/edit'  else '/found_friends')
      else
        @navigate(if @isSteps then '/user/edit' else '/user/edit/show')
      MyUser.refresh(if data.user then data.user else data)
    ).fail ( (data) =>
      @log 'Failed submitting form'
    )

  alert: (msg) ->
    @hideKeyboard()
    Spine.trigger 'notify', msg: msg, class: 'warn'

  checkValidity: ->
    if @form[0].checkValidity()
      @doneButton.removeClass 'disabled'
    else
      @doneButton.addClass 'disabled'

  onFocusPhone: (e) ->
    input = $(e.currentTarget)
    unless input.val()
      input.val('+1')

  onBlurPhone: (e) ->
    input = $(e.currentTarget)
    if input.val().length<3
      input.val('')

  onChangePhone: (e) ->
    input = $(e.currentTarget)
    console.log 'onChangePhone'
    val = input.val()
    unless val[0]=='+'
      Spine.trigger 'notify', msg: 'Add country code e.g: +1-212-....', class: 'warn'
      input.val('+') unless val.length

  back: ->
    if @item.id
      @navigate('/user/edit/show', trans: 'left')
    else
      @navigate('/please_login', trans: 'left')

  change: =>
    @item = MyUser.first()
    setTimeout(@setupPusher, 3000)
    @render()
    if @item.validate()
      @cancelButton.remove() if @cancelButton
    else
      @cancelButton = @addButton('Cancel', @back)

  setupPusher: =>
    return if @pusher
    @startDate = new Date()
    Spine.bind 'appResumed', ->
      @startDate = new Date()

    # Disable pusher on dev mode for now
#    return if Config.env=='development'

    @pusher = pubnub = PUBNUB(
      subscribe_key: 'sub-c84a4505-ef49-11e1-b9bf-9fa4c00b78db',
      ssl: false,
      origin: 'pubsub.pubnub.com'
    )

    pubnub.subscribe(
      restore: true,
      channel: "user_"+@item.id,
      callback : (message) ->
        console.log("pusher message: "+ message.cmd)
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
    @addButton('Settings', -> @navigate '/settings', trans: 'left').addClass('right')

  back: ->
    @navigate '/user/edit', trans: 'right'

  change: (params) =>
    super(id: 'my-user')


class UserEdit extends Spine.Controller
  constructor: ->
    super

    @form = new UserEditForm
    @show = new MyUserShow
    @login = new Login
    @settings = new Settings

    @routes
      '/user/edit/show': (params) -> @show.active(params)
      '/user/edit': (params) -> @form.active(params)
      '/user/login': (params) -> @login.active(params)
      '/settings': (params) -> @settings.active(params)

module.exports = UserEdit