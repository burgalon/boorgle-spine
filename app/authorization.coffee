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
        # This return status could be fired while trying to login,
        # in which case the controller (PleaseLogin) will handle this
        @promptLogin() if @is_loggedin()
      else if xhr.status is 422
        try
          strings = []
          for key, value of JSON.parse(xhr.responseText)
            strings.push key + ": " + value.join(', ')
          @alert strings.join ". "
        catch error
          @alert "Network Error: #{xhr.statusText}. #{xhr.responseText}"
      else
        try
          errorData = JSON.parse(xhr.responseText)
          @alert "Network Error: #{xhr.statusText}. #{errorData.message}"
        catch error
          @alert "Network Error: #{xhr.statusText}. #{xhr.responseText}"

    @loadToken()

  @setupAjax: ->
    if @token
      Spine.Ajax.defaults.headers['Authorization'] = @token
    else
      delete Spine.Ajax.defaults.headers['Authorization']

  @alert: (msg) ->
    Spine.trigger 'notify', msg: msg

  @deleteToken: ->
    @token = null
    delete localStorage['access_token']
    @setupAjax()

  @saveToken: (token) ->
    if token
      @token = localStorage['access_token'] = token
      @setupAjax()
    else
      return null

  @loadToken: ->
    token = document.location.hash.match(/access_token=(\w+)/)?[1]
    token = localStorage['access_token'] if localStorage['access_token']
    @saveToken token

  @getToken: ->
    @token

  @logout: ->
    @deleteToken()
    window.location.reload()
    if forge?
      forge.tabs.openWithOptions
        url: Config.oauthEndpoint.replace('/oauth/','/accounts/signout/')
        pattern: Config.oauthEndpoint.replace('/oauth/','/')
        title: 'Connect with GMail'
        (data) =>
          @deleteToken()
          window.location.reload()
    else
      @deleteToken()
      window.location.reload()

  @connectGmail: =>
    if Config.env=='ios'
      forge.tabs.openWithOptions
        url: @::oauthEndPoint
        pattern: 'boorgle://*'
        title: 'Connect with GMail'
        (data) =>
          @saveToken data.url.match(/access_token=(\w+)/)?[1]
          window.location.reload()
    else
      window.location = @::oauthEndPoint

  @promptLogin: ->
    @deleteToken()
    @alert "Invalid login. Please sign in again"
    Spine.Route.navigate '/please_login'

  @is_loggedin: ->
    !!@token

  @ajaxSettings: (params, defaults) ->
    $.extend({}, defaults, params)

  @ajax: (params) ->
    $.ajax(@ajaxSettings(params, Spine.Ajax.defaults))

  # Helper for setting sync/confirm/request ajaxes
  @friendAjax: (endpoint, friend_id, params) ->
    defaults =
      url: Spine.Model.host+'/'+endpoint
      type: 'POST'
      data: JSON.stringify(friend_id: friend_id)
    params = $.extend({}, defaults, params)
    @ajax(params)


module.exports = Authorization