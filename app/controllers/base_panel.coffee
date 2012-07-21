{Panel} = require('spine.mobile')

class BasePanel extends Panel
  activate: ->
    super
    console.log 'trigger activateTab', @tab
    Spine.trigger 'activateTab', @tab

module.exports = BasePanel