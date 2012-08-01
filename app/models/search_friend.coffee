Spine = require('spine')
User = require('./user')
GmailUser = require('./gmail_user')

class SearchFriend extends User
  @configure 'SearchFriend'
  @extend Spine.Model.Ajax
  @collection_types: ['System', 'Gmail']
  # Collections that are updated as a result
  @System: User
  @Gmail: GmailUser

  # Looks for object in the sub-collections
  @exists: (id) ->
    for key in @collection_types
      ret = @[key].exists(id)
      return ret if ret
    return false

  # Break-down the response to all sub-collections
  @fromJSON: (objects) ->
    return unless objects
    if typeof objects is 'string'
      objects = JSON.parse(objects)

    # Do some customization...
    for key in @collection_types
      underscore_key =  key.replace(/([a-z])([A-Z])/g, '$1_$2').toLowerCase()
      @[key].refresh(objects[underscore_key] || [])
    return []

  @url: ->
    throw 'No q value' unless @q
    Spine.Model.host + "/search_friends?q="+encodeURIComponent(@q)

  # Saves the 'q' to this so that @url() has access to it
  @fetch: (@q) ->
    super

module.exports = SearchFriend