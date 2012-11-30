{Panel} = require('spine.mobile')

class BasePanel extends Panel
  constructor: ->
    super
    @content.addClass('overthrow')

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