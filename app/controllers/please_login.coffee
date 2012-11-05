Spine = require('spine')
Authorization = require('/authorization')
BasePanel = require('./base_panel')

class PleaseLogin extends BasePanel
  className: 'please_login'
  events:
    'tap .gmail': 'gmailButton'
    'tap .signup': 'signupButton'
    'tap .login': 'loginButton'

  constructor: ->
    super
    @active @render

  render: =>
    @html require('views/users/please_login')()

  gmailButton: ->
    Authorization.connectGmail()

  signupButton: ->
    @navigate '/user/edit', trans: 'right'

  loginButton: ->
    @navigate '/user/login', trans: 'right'

module.exports = PleaseLogin