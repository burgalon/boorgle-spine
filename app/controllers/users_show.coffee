{Panel} = require('spine.mobile')

class UsersShow extends Panel
  className: 'users showView'

  @configure: (@model_class) ->

  constructor: ->
    super

    @constructor.model_class.bind 'refresh', @change

    @active @change
    @add_buttons()

  add_buttons: ->
    @addButton('Back', @back)

  render: =>
    return unless @item
    @html require('views/users/show')(@item)

  # Called when a user is clicked on
  change: (params) =>
    @item_id = params.id if params.id
    @item = @constructor.model_class.exists(@item_id)
    @render()

  back: ->
    @log 'Missing back button'

module.exports = UsersShow