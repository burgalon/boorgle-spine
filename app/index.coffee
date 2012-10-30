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

if Config.env=='ios'
  # This monkey-patch is necessary for Android 2.2 where COR is having problems with Authorization headers
  $.ajax = (options) ->
    # console.log 'forge ajax', options
    dfd = jQuery.Deferred()
    options.success = (data) ->
      # console.log "forge ajax resolve", data
      dfd.resolve data

    options.error = (error) ->
      console.log "forge ajax reject", error
      error.responseText = error.content
      error.statusText = error.message
      error.status = parseInt(error.statusCode)
      # arguments: event, xhr, ajaxSettings, thrownError
      dfd.reject event, error
      $(document).trigger 'ajaxError', error

    forge.ajax options
    dfd.promise()

class App extends Stage.Global
  Authorization: Authorization

  constructor: ->
    super
    @setupAJAX()

    Authorization.setup()

    # Reload data when resumed
    forge.event.appResumed.addListener(@appResumed) if Config.env=='ios'
    setTimeout(@fetchData, 500)

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

    unless Authorization.is_loggedin()
      @el.addClass('loggedout')

    # General initializations
    Spine.bind 'notify', @notify
    Spine.bind 'activateTab', @activateTab
    Spine.Route.setup()#shim:true)

    unless document.location.hash && !document.location.hash.match('#access_token')
      if Authorization.is_loggedin()
        @navigate '/found_friends'
      else
        @navigate '/please_login'

  appResumed: =>
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
    FoundFriend.fetch()
    if Authorization.is_loggedin()
      MyUser.fetch()
      Friend.fetch()

  setupAJAX: ->
    el = $('<div id="loading"></div>').prependTo($('body')).hide()
    el.ajaxSend( (e, xhr, options) ->
      return unless options.url.match(Spine.Model.host)
      el.show()
    ).ajaxStop( =>
      el.hide()
    )

module.exports = App