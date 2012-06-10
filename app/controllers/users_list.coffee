{Panel} = require('spine.mobile')

class UsersList extends Panel
  events:
    'tap .item': 'click'

  title: 'Abstract List'

  className: 'users list listView'

  @configure: (@model_class) ->

  constructor: ->
    super

    @constructor.model_class.bind 'refresh change', @render

  render: =>
    items = @constructor.model_class.all()
    @html require('views/users/item')(items)

  click: (e) ->
    @log 'TARGET', $(e.target)
#    item = $(e.target).item()
    element = $(e.target)
    item = element.data('item')
    @log 'UsersList::click ', item, item.id
    @navigate('/users', item.id, trans: 'right')

  add: ->
    @navigate('/users/create', trans: 'right')

module.exports = UsersList