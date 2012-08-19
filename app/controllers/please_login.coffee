Spine = require('spine')
Authorization = require('/authorization')
BasePanel = require('./base_panel')

class PleaseLogin extends BasePanel
  className: 'please_login'
  tab: 'account'
  events:
    'tap .login-button': 'loginButton'

  constructor: (title, @tab) ->
    super
    @setTitle(title)

    @active @render

  render: =>
    @html require('views/users/please_login')()

  loginButton: ->
    Authorization.login()

module.exports = PleaseLogin