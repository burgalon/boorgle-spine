BasePanel = require('./base_panel')
Authorization = require('authorization')

class Settings extends BasePanel
  title: 'Settings'
  tab: 'account'
  events:
    'tap .logout': 'logout'
    'tap .sync': 'sync'

  constructor: ->
    super
    @active @render

  add_buttons: ->
    @addButton('Cancel', -> @navigate '/user/edit/show', trans: 'left')

  render: =>
    @html require('views/users/settings')()

  logout: ->
    @navigate '/please_login'
    Authorization.logout()

  sync: ->
    url = Config.host + '/user/apple_sync_profile'
    url+='?oauth_token='+ Authorization.getToken()
    if window.cordova
      @deleteToken()
      if window.device.platform.indexOf('Android')!=-1
        navigator.app.loadUrl url
      else
        window.location = url
    else
      window.open  url



module.exports = Settings