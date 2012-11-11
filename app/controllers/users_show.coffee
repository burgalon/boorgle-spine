Authorization = require('authorization')

# Models
FoundFriend = require('models/found_friend')
Friend = require('models/friend')

BasePanel = require('./base_panel')

# Abstract
class UsersShow extends BasePanel
  className: 'users showView'

  @configure: (@model_class) ->

  constructor: ->
    super

    @constructor.model_class.bind 'refresh', @change

    @active @change
    @add_buttons()

  # Called when a user is clicked on
  change: (params) =>
    @item_id = params.id if params.id
    @item = @constructor.model_class.exists(@item_id)
    @render()

  back: ->
    @log 'Missing back button'

  clear_buttons: ->
    $('button', @header).remove()

  render: =>
    return unless @item
    @clear_buttons()
    @add_buttons()
    @html require('views/users/show')(@item)

  add_buttons: ->
    @addButton('All Contacts', @back).addClass('back')
    return unless @item
    if @item.constructor.className=='Pending'
      # @addButton('Add', @add).addClass('right')
      return
    else if @item.constructor.className=='Confirm'
      @addButton('Confirm', @confirm).addClass('right')
    else if @item.constructor.className=='Friend'
      @addButton('Delete', @delete).addClass('right')
    else
      @addButton('Add', @add).addClass('right')

  delete: ->
    # _method: 'DELETE' is a hack because forge.ajax which sends DELETE requests as GET
    Authorization.friendAjax('friends/'+ @item.id, @item.id,
      contentType: 'application/x-www-form-urlencoded; charset=UTF-8'
      data: $.param
        _method: 'DELETE'
        friend_id: @item.id
    ).done =>
      FoundFriend.fetch()
      Friend.fetch()
      @navigate '/friends'

  # Confirm pending request
  confirm: ->
    return @navigate('/user/edit', trans: 'left') unless Authorization.is_loggedin()
    Authorization.friendAjax('friends', @item.id).done( =>
              FoundFriend.fetch()
              Friend.fetch()
              @navigate '/friends'
            )

  # Request to sync
  add: (e) ->
    el = $(e.target)
    el.addClass('disabled')
    return @navigate('/user/edit', trans: 'left') unless Authorization.is_loggedin()
    Authorization.friendAjax('pending_friends', @item.id).done( =>
          FoundFriend.fetch()
          @navigate '/found_friends'
        )


module.exports = UsersShow