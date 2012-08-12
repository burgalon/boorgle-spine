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
FoundFriends = require('controllers/found_friends')
Friends = require('controllers/friends')
UserEdit = require('controllers/user_edit')
Notifications = require('controllers/notifications')

#Spine.Model.host = if document.location.href.match(/localhost|192./) then "http://localhost:3000/api/v1" else "http://www.boorgle.com/api/v1"
Spine.Model.host = Config.host

class App extends Stage.Global
  Authorization: Authorization

  constructor: ->
    super
    @setupAJAX()

    Authorization.setup()

    # Models
    FoundFriend.fetch()
    if Authorization.is_loggedin()
      MyUser.fetch()
      Friend.fetch()

    # Controllers
    @user_edit = new UserEdit
    @found_friends = new FoundFriends
    @friends = new Friends
    @notifications = new Notifications

    @addTab('Explore', -> @navigate '/found_friends')
    @addTab('Contacts', -> @navigate '/friends')
    @addTab('Account', -> @navigate '/user/edit/show')

    # General initializations
    Spine.bind 'notify', @notify
    Spine.bind 'activateTab', @activateTab
    Spine.Route.setup()#shim:true)
#    @navigate '/found_friends'
#    @navigate '/user/edit'
    @navigate '/found_friends' unless document.location.hash && !document.location.hash.match('#access_token')

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

  setupAJAX: ->
    el = $('<div id="loading">Loading</div>').appendTo($('body'))
    el.ajaxStart(
      () ->
        el.addClass('loading')
    ).ajaxStop(
      () ->
        f = -> el.removeClass('loading')
        setTimeout(f,500)
    )

module.exports = App