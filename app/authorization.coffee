Config = require('./config')
Spine   = require('spine')
App = require("index")

class Authorization extends Spine.Module
  clientId: Config.clientId
  oauthEndPoint: "#{Config.oauthEndpoint}authorize?client_id=#{@::clientId}&response_type=token&redirect_uri=#{Config.oauthRedirectUri}"

  @setup: ->
    $(document).on 'ajaxError', (event, xhr, ajaxSettings, thrownError) =>
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
          @alert "Network Error (1): #{xhr.statusText}. #{xhr.responseText}"
      else
        try
          errorData = JSON.parse(xhr.responseText)
          @alert "Network Error (2): #{xhr.statusText}. #{errorData.message}"
        catch error
          @alert "Network Error (3): #{xhr.statusText}. #{xhr.responseText}"

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
    if window.cordova
      if window.device.platform.indexOf('Android')!=-1
        navigator.app.loadUrl Config.oauthEndpoint.replace('/oauth/','/accounts/sign_out/')
      else
        window.location = Config.oauthEndpoint.replace('/oauth/','/accounts/sign_out/')
    else if window.forge
      forge.tabs.openWithOptions
        url: Config.oauthEndpoint.replace('/oauth/','/accounts/sign_out/')
        pattern: Config.oauthEndpoint.replace('/oauth/','/')
        title: 'Connect with GMail'
        (data) =>
          @deleteToken()
          window.location.reload()
    else
      @deleteToken()
      window.location.reload()

  @connectGmail: =>
    if window.forge
      forge.tabs.openWithOptions
        url: @::oauthEndPoint
        pattern: 'boorgle://*'
        title: 'Connect with GMail'
        (data) =>
          token = data.url.match(/access_token=(\w+)/)?[1]
          return unless token
          @saveToken token
          Spine.trigger 'login' if @token
    else if window.cordova
      if window.device.platform.indexOf('Android')!=-1
        navigator.app.loadUrl @::oauthEndPoint
      else
        window.location = @::oauthEndPoint
    else
      window.location = @::oauthEndPoint

  @handleOpenURL: =>
    # This is being checked by appResumed since handleOpenURL is fired together with appResumed
    window.handleOpenURLProcessing = true
    @loadToken()
    Spine.trigger 'login' if @token
    setTimeout (-> delete window.handleOpenURLProcessing), 5000

  @promptLogin: ->
    @deleteToken()
    @alert "Invalid login. Please sign in again"
    Spine.Route.navigate '/please_login'

  @is_loggedin: ->
    !!@token

  @ajaxSettings: (params, defaults) ->
    if params.headers
      params.headers = $.extend({}, Spine.Ajax.defaults.headers, params.headers)
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