Spine = require('spine')
User = require('./user')

# Collections
# Users near you
class Near extends User
  @configure 'Near'
# Users who signed up to the system recently
class Recent extends User
  @configure 'Recent'
# Users who requestsed to connect with you
class Confirm extends User
  @configure 'Confirm'
# Users who requested to connect with you, but you decided to ignore from
class IgnoredConfirm extends User
  @configure 'IgnoredConfirm'
# Users from your gmail that you decided to ignore
class IgnoredFound extends User
  @configure 'IgnoredFound'
# Users found from your gmail account
class Gmail extends User
  @configure 'Gmail'
# User you requested to connect with
class Pending extends User
  @configure 'Pending'


class FoundFriend extends User
  @configure 'FoundFriend'
  @extend Spine.Model.Ajax
  @url: ->
    Spine.Model.host + "/found_friends"

  @collection_types: ['Confirm', 'Near', 'Gmail', 'Recent', 'Pending', 'IgnoredConfirm', 'IgnoredFound']
  # Collections that are updated as a result
  @Confirm: Confirm
  @Near: Near
  @Recent: Recent
  @IgnoredConfirm: IgnoredConfirm
  @IgnoredFound: IgnoredFound
  @Gmail: Gmail
  @Pending: Pending

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

#    if Spine.isArray(objects)
#      (new @(value) for value in objects)
#    else
#      new @(objects)

  @fetch: ->
    navigator.geolocation.getCurrentPosition((location) =>
      location.created_at = new Date()
      Spine.Ajax.defaults.headers['X-Location'] = [location.coords.latitude, location.coords.longitude, location.coords.accuracy].join(',')
      super
      console.log 'Retrieved location', location
    , ((error) ->
      console.log 'Could not get location'
    ))

module.exports = FoundFriend