{Panel} = require('spine.mobile')

class BasePanel extends Panel
  activate: ->
    super
    Spine.trigger 'activateTab', @tab

module.exports = BasePanel