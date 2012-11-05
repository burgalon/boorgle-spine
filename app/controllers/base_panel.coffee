{Panel} = require('spine.mobile')

class BasePanel extends Panel
  activate: ->
    @hideKeyboard()
    super
    Spine.trigger 'activateTab', @tab

  addButton: (text, callback) ->
    super.addClass('button')

  hideKeyboard: ->
    document.activeElement.blur();
    $("input").blur();

module.exports = BasePanel