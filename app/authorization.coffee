class Authorization extends Spine.Module
  clientId: 'boorgle-iphone'
  oauthEndPoint: "http://localhost:3000/oauth/authorize?client_id=#{@::clientId}&response_type=token&redirect_uri=#{encodeURIComponent(window.location)}"

  @setup: ->
    $(document).ajaxError (xhr, status, error) =>
      console.log("Global ajaxError", arguments)
      console.log("XHR.status", xhr.status)
      if xhr.status is 401
        @login()
      else if xhr.status is 500
        alert('Server Error')
      else if xhr.status is 403
        alert('Bad Request')
      else
        alert('Network Error')

    @token = @getToken()
    if @token
      Spine.Ajax.defaults.headers['Authorization'] = @token

  @getToken: ->
    token = document.location.hash.match(/access_token=(\w+)/)?[1]
    localStorage['access_token'] = token if token
    localStorage['access_token'] || null

  @logout: ->
    delete localStorage['access_token']
    document.location.reload()

  @login: ->
    if confirm("Invalid login. Singin again?")
      window.location = @::oauthEndPoint

  @is_loggedin: ->
    !!@token

module.exports = Authorization