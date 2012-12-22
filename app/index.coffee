require('lib/setup')

Spine   = require('spine')
{Stage} = require('spine.mobile')

window.Config = Config = require('./config')
Authorization = require('authorization')

# Models
Friend = require('models/friend')
FoundFriend = require('models/found_friend')
MyUser = require('models/my_user')

# Controllers
PleaseLogin = require('controllers/please_login')
FoundFriends = require('controllers/found_friends')
Friends = require('controllers/friends')
UserEdit = require('controllers/user_edit')
Notifications = require('controllers/notifications')

#Spine.Model.host = if document.location.href.match(/localhost|192./) then "http://localhost:3000/api/v1" else "http://www.boorgle.com/api/v1"
Spine.Model.host = Config.host
Spine.Ajax.defaults.headers['X-Version'] = Config.version

if window.forge
  # This monkey-patch is necessary for Android 2.2 where COR is having problems with Authorization headers
  ajaxCounter = 0
  $.ajax = (options) ->
    # console.log 'forge ajax', options
    dfd = jQuery.Deferred()
    options.success = (data) ->
      # console.log "forge ajax resolve", data
      ajaxCounter--
      unless ajaxCounter
        $(document).trigger 'ajaxStop', [null, options]
      dfd.resolve data

    options.error = (error) ->
      console.log "forge ajax reject", error
      error.responseText = error.content
      error.statusText = error.message
      error.status = parseInt(error.statusCode)

      ajaxCounter--
      unless ajaxCounter
        $(document).trigger 'ajaxStop', [null, options]

      # arguments: event, xhr, ajaxSettings, thrownError
      dfd.reject error
      $(document).trigger 'ajaxError', error

    $(document).trigger 'ajaxSend', [null, options]
    ajaxCounter++
    forge.ajax options
    dfd.promise()

class App extends Stage.Global
  Authorization: Authorization

  constructor: ->
    super
    @setupAJAX()

    Authorization.setup()

    if window.cordova
      document.addEventListener 'resume', @appResumed

    if window.forge
      @el.addClass(if forge.is.ios() then 'ios' else 'android')
      forge.event.appResumed.addListener(@appResumed)
      forge.event.backPressed.preventDefault =>
        forge.logging.log('Success preventing default back button action');

    setTimeout(@fetchData, 500)
    Spine.bind 'login', @onLogin

    # Controllers
    @user_edit = new UserEdit
    @found_friends = new FoundFriends
    @friends = new Friends
    @notifications = new Notifications

    @addTab('Explore', -> @navigate '/found_friends')
    @addTab('Contacts', -> @navigate '/friends')
    @addTab('Account', -> @navigate '/user/edit/show')

    @please_login = new PleaseLogin()
    @routes
      '/please_login': (params) -> @please_login.active(params)

    # Start by default from loggedout state
    # once MyUser is refreshed and valid, we will remove this class which hides the tabbar
    @el.addClass('loggedout')

    # General initializations
    Spine.bind 'notify', @notify
    Spine.bind 'activateTab', @activateTab
    Spine.Route.setup()#shim:true)

    if Authorization.is_loggedin()
      Spine.trigger 'login'
    else
      @navigate '/please_login'

    forge.launchimage.hide() if window.forge

  appResumed: =>
    @log 'appResumed'
    @fetchData()
    Spine.trigger 'appResumed'

  activateTab: (tabClass) ->
    $('footer .nav-item').removeClass('active')
    $('footer .'+tabClass).addClass('active')

  notify: (item) =>
    @notifications.render(item)

  addTab: (text, callback) ->
    callback = @[callback] if typeof callback is 'string'
    button=$('<i class="icon '+text.toLowerCase()+'"></i><div class="nav-label">'+text+'</div>')
    wrapper = $("<div/>").addClass('nav-item ' + text.toLowerCase()).append(button)
    wrapper.tap(@proxy(callback))
    @footer.append(wrapper)
    button

  fetchData: =>
    return unless Authorization.is_loggedin()
    MyUser.fetch()
    FoundFriend.fetch()
    Friend.fetch()

  onLogin: =>
    @navigate '/found_friends'
    MyUser.one 'refresh', =>
      # Let user edit his profile if he is missing details
      if MyUser.exists(@item_id).validate()
        @navigate '/user/edit'
      else
        $('body').removeClass('loggedout')
    @fetchData()

  setupAJAX: ->
    el = $('<div id="loading"></div>').prependTo($('body')).hide()
    counter=0
    $(document).ajaxSend( (e, xhr, options) ->
      el.show() if options.url.match(Spine.Model.host)
    ).ajaxStop( =>
      el.hide()
    )

module.exports = App