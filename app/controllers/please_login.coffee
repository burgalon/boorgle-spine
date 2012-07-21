Spine = require('spine')
BasePanel = require('./base_panel')

class PleaseLogin extends BasePanel
  className: 'please_login'
  tab: 'account'

  constructor: (title, @tab) ->
    super
    @setTitle(title)

    @active @render

  render: =>
    @html require('views/users/please_login')()

module.exports = PleaseLogin