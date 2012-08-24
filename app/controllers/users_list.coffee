BasePanel = require('./base_panel')
Authorization = require('authorization')

# Model
GmailUser = require('models/gmail_user')

class UsersList extends BasePanel
  events:
    'tap .invite': 'invite'
    'tap .item': 'click'

  title: 'Abstract List'

  className: 'users list listView'

  @configure: (@model_class, @item_url) ->

  scrollTop: 0

  constructor: ->
    super

    @constructor.model_class.bind 'refresh change', @render
    @panel = @el.find('article')
    @panel.bind 'scroll', @proxy(@scroll)

  activate: ->
    f = () => @panel.scrollTop(@scrollTop) if @panel
    setTimeout(f,10)
    super

  render: =>
    @html require('views/users/item')(@constructor.model_class.all())

  scroll: (e) ->
    @scrollTop = $(e.target).scrollTop()

  click: (e) ->
    e.preventDefault()
    element = $(e.currentTarget)
    item = element.data('item')
    @log 'UsersList::click ', item, item.id
    # Do not go into detail view for GmailUsers. We don't have enough details to show anything interesting
    return if item instanceof GmailUser
    @navigate(@constructor.item_url, item.id, trans: 'right')

  invite: (e) ->
    e.preventDefault()
    element = $(e.currentTarget).parents('.item')
    item = element.data('item')
    console.log('item', item)
    return unless confirm("Would you like to invite #{item.name} (#{item.email}}")
    Spine.trigger 'notify', msg: 'Sending invite email to ' + item.email
    Authorization.friendAjax('invites', item.id)

  add: ->
    @navigate('/users/create', trans: 'right')

module.exports = UsersList