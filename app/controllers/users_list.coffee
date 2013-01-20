BasePanel = require('./base_panel')
Authorization = require('authorization')

# Model
FoundFriend = require('models/found_friend')
GmailUser = require('models/gmail_user')

class UsersList extends BasePanel
  title: 'Abstract List'

  className: 'users list listView'

  @configure: (@model_class, @item_url) ->

  scrollTop: 0

  constructor: ->
    @events = $.extend @events || {},
      'tap .invite': 'invite'
      'tap .item': 'click'
      'touchstart .item': 'touch'
      'touchend .item': 'touchend'
      'touchcancel .item': 'touchend'
      'touchmove .item': 'touchend'
      'touchleave .item': 'touchend'

    super

    @constructor.model_class.bind 'refresh change', @render
    @panel = @el.find('article')

  activate: ->
    f = () => @panel.scrollTop(@scrollTop) if @panel
    setTimeout(f,10)
    super

  render: =>
    @html require('views/users/item')(@constructor.model_class.all())

  saveScroll: (e) ->
    @scrollTop = @panel.scrollTop()

  touch: (e) ->
    $(e.currentTarget).addClass('active')

  touchend: (e) ->
    $(e.currentTarget).removeClass('active')

  click: (e) ->
    @saveScroll()
    element = $(e.currentTarget)
    item = element.data('item')
    @log 'UsersList::click ', item, item.id
    # Do not go into detail view for GmailUsers. We don't have enough details to show anything interesting
    return if item instanceof GmailUser
    @navigate(@constructor.item_url, item.id, trans: 'right')

  invite: (e) ->
    element = $(e.currentTarget).parents('.item')
    item = element.data('item')
    console.log('item', item)
    @delay ->
      return unless confirm("Would you like to invite #{item.name} (#{item.email})")
      Spine.trigger 'notify', msg: 'Sending invite email to ' + item.email
      Authorization.friendAjax('invites', item.id).done =>
        FoundFriend.fetch()
    false

  add: ->
    @navigate('/users/create', trans: 'right')

module.exports = UsersList