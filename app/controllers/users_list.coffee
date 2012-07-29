BasePanel = require('./base_panel')

class UsersList extends BasePanel
  events:
    'tap .item': 'click'

  title: 'Abstract List'

  className: 'users list listView'

  @configure: (@model_class, @item_url) ->

  constructor: ->
    super

    @constructor.model_class.bind 'refresh change', @render

  render: =>
    @html require('views/users/item')(@constructor.model_class.all())

  click: (e) ->
    element = $(e.currentTarget)
    item = element.data('item')
    @log 'UsersList::click ', item, item.id
    @navigate(@constructor.item_url, item.id, trans: 'right')

  add: ->
    @navigate('/users/create', trans: 'right')

module.exports = UsersList