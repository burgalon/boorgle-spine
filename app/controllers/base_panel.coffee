{Panel} = require('spine.mobile')

class BasePanel extends Panel
  activate: ->
    super
    Spine.trigger 'activateTab', @tab

  addButton: (text, callback) ->
    super.addClass('button')

module.exports = BasePanel