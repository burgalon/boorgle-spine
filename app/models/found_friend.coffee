Spine = require('spine')
User = require('./user')
GmailUser = require('./gmail_user')

# Collections
class UserCollection extends User
  @pluralLowerCase: ->
    'users'

# Users who requestsed to connect with you
class Confirm extends UserCollection
  @configure 'Confirm'
# Users near you
class Near extends UserCollection
  @configure 'Near'
# Users found from your gmail account
class Gmail extends UserCollection
  @configure 'Gmail'
# Users found from your gmail account and are NOT on Boorgle (need invite)
class GmailInvite extends GmailUser
# Users who signed up to the system recently
class Recent extends UserCollection
  @configure 'Recent'
# User you requested to connect with
class Pending extends UserCollection
  @configure 'Pending'
# Users who requested to connect with you, but you decided to ignore from
class IgnoredConfirm extends UserCollection
  @configure 'IgnoredConfirm'
# Users from your gmail that you decided to ignore
class IgnoredFound extends UserCollection
  @configure 'IgnoredFound'


class FoundFriend extends UserCollection
  @configure 'FoundFriend'
  @extend Spine.Model.Ajax
  @url: ->
    Spine.Model.host + "/found_friends"

  @collection_types: ['Confirm', 'Near', 'Gmail', 'GmailInvite', 'Recent', 'Pending', 'IgnoredConfirm', 'IgnoredFound']
  # Collections that are updated as a result
  @Confirm: Confirm
  @Near: Near
  @Recent: Recent
  @IgnoredConfirm: IgnoredConfirm
  @IgnoredFound: IgnoredFound
  @Gmail: Gmail
  @GmailInvite: GmailInvite
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
    if Config.env=='ios'
      forge.geolocation.getCurrentPosition({enableHighAccuracy: true}, (location) =>
        location.created_at = new Date()
        Spine.Ajax.defaults.headers['X-Location'] = [location.coords.latitude, location.coords.longitude, location.coords.accuracy].join(',')
        super()
        console.log 'Retrieved location', location
      , (error) =>
        console.log 'Could not get location'
        super()
      )
    else
      # If no geolocation interface on this browser
      return super unless navigator.geolocation?
      navigator.geolocation.getCurrentPosition( (location) =>
        location.created_at = new Date()
        Spine.Ajax.defaults.headers['X-Location'] = [location.coords.latitude, location.coords.longitude, location.coords.accuracy].join(',')
        super()
        console.log 'Retrieved location', location
      , (error) =>
        console.log 'Could not get location'
        super()
      )

module.exports = FoundFriend