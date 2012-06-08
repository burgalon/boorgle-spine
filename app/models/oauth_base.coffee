Spine = require('spine')

class OauthBase extends Spine.Module
#  @extend Spine.Model.Ajax
#  @ajaxPrefix: true
#
#  @fetch: ->
#    return [] unless localStorage['oauth_token']
#    console.log "FETCH ", localStorage['oauth_token']
#    super(headers: {'Authorization': localStorage['oauth_token']})

module.exports = OauthBase