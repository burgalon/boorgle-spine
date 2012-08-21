if document.location.href.match(/localhost|192./)
#   # Development
#   Config =
#     env: 'development'
#     host: 'http://localhost:3000/api/v1'
#     clientId: 'boorgle-web-mobile-localhost'
#     oauthEndpoint: 'http://localhost:3000/oauth/'
#     oauthRedirectUri: 'http://localhost:9294'

  # Development against production
  Config =
   env: 'development'
   host: 'http://www.boorgle.com/api/v1'
   clientId: 'boorgle-web-mobile-localhost'
   oauthEndpoint: 'http://www.boorgle.com/oauth/'
   oauthRedirectUri: 'http://localhost:9294'

else if document.location.href.match(/file:\/\//)
  # iPhone Native
  Config =
    env: 'ios'
    host: 'http://www.boorgle.com/api/v1'
    clientId: 'boorgle-iphone'
    oauthEndpoint: 'http://www.boorgle.com/oauth/'
    oauthRedirectUri: 'boorgle:///'

else
  # Production
  Config =
    env: 'production'
    host: 'http://www.boorgle.com/api/v1'
    clientId: 'boorgle-web-mobile'
    oauthEndpoint: 'http://www.boorgle.com/oauth/'
    oauthRedirectUri: 'http://m.boorgle.com'

module.exports = Config
