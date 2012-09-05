Spine   = require('spine')
{Stage} = require('spine.mobile')

class Notifications extends Spine.Controller

  className: 'notifications'
  constructor: ->
    super
    @stage ?= Stage.globalStage()
    @stage?.add(@)

  render: (item) =>
    @html require('views/notifications/show')(item)
    @el.addClass('on').on 'tap', =>
      @el.removeClass('on')


module.exports = Notifications