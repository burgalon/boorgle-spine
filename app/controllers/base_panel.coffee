{Panel} = require('spine.mobile')

class BasePanel extends Panel
  activate: ->
    super
    Spine.trigger 'activateTab', @tab

  addButton: (text, callback) ->
    super.addClass('button')

  activate: ->
    # Hide keyboard if was open
    document.activeElement.blur();
    $("input").blur();
    super


module.exports = BasePanel