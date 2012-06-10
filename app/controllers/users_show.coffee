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
    @log 'UsersShow::render item - ', @item
    return unless @item
    @html require('views/users/show')(@item)

  # Called when a user is clicked on
  change: (params) =>
    @log 'UsersShow::change params - ', params
    @item = @constructor.model_class.find(params.id) if params.id
    @render()

  back: ->
    @log 'Missing back button'

module.exports = UsersShow