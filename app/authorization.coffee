Config = require('./config')
Spine   = require('spine')
App = require("index")

class Authorization extends Spine.Module
  clientId: Config.clientId
  oauthEndPoint: "#{Config.oauthEndpoint}authorize?client_id=#{@::clientId}&response_type=token&redirect_uri=#{Config.oauthRedirectUri}"

  @setup: ->
    $(document).ajaxError (event, xhr, ajaxSettings, thrownError) =>
      console.log("Global ajaxError", arguments)
      console.log("XHR.status", xhr.status)
      console.log("XHR.responseText", xhr.responseText)
      if xhr.status is 401
        @promptLogin()
      else if xhr.status is 500
        @alert('Server Error')
      else if xhr.status is 403
        @alert('Bad Request')
      else
        @alert('Network Error')

    @token = @getToken()
    @setupAjax()

  @setupAjax: ->
    if @token
      Spine.Ajax.defaults.headers['Authorization'] = @token
    else
      delete Spine.Ajax.defaults.headers['Authorization']

  @alert: (msg) ->
    Spine.trigger 'notify', msg: msg

  @saveToken: (token) ->
    localStorage['access_token'] = token if token
    localStorage['access_token'] || null

  @getToken: ->
    token = document.location.hash.match(/access_token=(\w+)/)?[1]
    @saveToken token

  @logout: ->
    delete localStorage['access_token']
    @token = null
    window.location.reload()

  @login: =>
    if Config.env=='ios'
      forge.tabs.openWithOptions(
        url: @::oauthEndPoint
        pattern: 'boorgle://*'
        title: 'Connect with GMail'
      , (data) =>
        @token = data.url.match(/access_token=(\w+)/)?[1]
        @saveToken @token
        window.location.reload()
      )
    else
      window.location = @::oauthEndPoint

  @promptLogin: ->
    delete localStorage['access_token']
    if confirm("Invalid login. Singin again?")
      @login()
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