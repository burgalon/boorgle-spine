{Panel} = require('spine.mobile')

class UsersShow extends Panel
  className: 'users showView'

  @configure: (@model_class) ->

  constructor: ->
    super

    @constructor.model_class.bind 'change', @render

    @active @change
    @add_buttons()

  add_buttons: ->
    @addButton('Back', @back)

  render: =>
    @log 'UsersShow::render', @item
    return unless @item
    @html require('views/users/show')(@item)

  # Called when a user is clicked on
  change: (params) ->
    # TODO: Figure why the exception catching is causing reload not to resume from the same address
    try
      @item = @constructor.model_class.find(params.id)
    catch e # Unknown record
      return false
    @render()

  back: ->
    @log 'Missing back button'

module.exports = UsersShow