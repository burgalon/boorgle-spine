Spine = require('spine')
{Panel} = require('spine.mobile')

class PleaseLogin extends Panel
  className: 'please_login'

  constructor: (title) ->
    super
    @setTitle(title)

    @active @render

  render: =>
    @html require('views/users/please_login')()

module.exports = PleaseLogin