Config = require('./config')

class Authorization extends Spine.Module
  clientId: Config.clientId
  oauthEndPoint: "#{Config.oauthEndpoint}authorize?client_id=#{@::clientId}&response_type=token&redirect_uri=#{encodeURIComponent(window.location.href.replace(/#.+/,''))}"

  @setup: ->
    $(document).ajaxError (event, xhr, ajaxSettings, thrownError) =>
      console.log("Global ajaxError", arguments)
      console.log("XHR.status", xhr.status)
      console.log("XHR.responseText", xhr.responseText)
      if xhr.status is 401
        @login()
      else if xhr.status is 500
        @alert('Server Error')
      else if xhr.status is 403
        @alert('Bad Request')
      else
        @alert('Network Error')

    @token = @getToken()
    if @token
      Spine.Ajax.defaults.headers['Authorization'] = @token

  @alert: (msg) ->
    Spine.trigger 'notify', msg: msg

  @getToken: ->
    token = document.location.hash.match(/access_token=(\w+)/)?[1]
    localStorage['access_token'] = token if token
    localStorage['access_token'] || null

  @logout: ->
    delete localStorage['access_token']
    document.location.reload()

  @login: ->
    delete localStorage['access_token']
    if confirm("Invalid login. Singin again?")
      window.location = @::oauthEndPoint
    else
      window.location = '/'

  @is_loggedin: ->
    !!@token

  @ajax: (params) ->
    $.ajax($.extend({}, Spine.Ajax.defaults, params))

  # Helper for setting sync/confirm/request ajaxes
  @friendAjax: (endpoint, friend_id, params) ->
    defaults =
      url: Spine.Model.host+'/'+endpoint
      type: 'POST'
      data: JSON.stringify(friend_id: friend_id)
    params = $.extend({}, defaults, params)
    @ajax(params)


module.exports = Authorization