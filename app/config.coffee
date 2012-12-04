if document.location.href.match(/localhost|192./)
   # Development
  Config =
    env: 'development'
    host: 'http://localhost:3000/api/v1'
    clientId: 'boorgle-web-mobile-localhost'
    oauthEndpoint: 'http://localhost:3000/oauth/'
    oauthRedirectUri: 'http://localhost:9294'

#  # Development against production
#  Config =
#   env: 'development'
#   host: 'http://www.boorgle.com/api/v1'
#   clientId: 'boorgle-web-mobile-localhost'
#   oauthEndpoint: 'http://www.boorgle.com/oauth/'
#   oauthRedirectUri: 'http://localhost:9294'

#  # Development against staging
#  Config =
#   env: 'staging'
#   host: 'http://boorgle-staging.herokuapp.com/api/v1'
#   clientId: 'boorgle-web-mobile-localhost'
#   oauthEndpoint: 'http://boorgle-staging.herokuapp.com//oauth/'
#   oauthRedirectUri: 'http://localhost:9294'

else if forge?
  # iPhone Native
  Config =
    env: 'ios'
    host: 'http://www.boorgle.com/api/v1'
    clientId: 'boorgle-iphone'
    oauthEndpoint: 'http://www.boorgle.com/oauth/'
    oauthRedirectUri: 'boorgle:///'

#  # iPhone Native local
#  Config =
#    env: 'ios'
#    host: 'http://localhost:3000/api/v1'
#    clientId: 'boorgle-iphone'
#    oauthEndpoint: 'http://localhost:3000/oauth/'
#    oauthRedirectUri: 'boorgle:///'

  #  # !!!!!!!!!!!!!BEWARE!!!!!!!!!!!!!
  #  # Do not publish staging environment to production app
  #  # Staging
  #  Config =
  #    env: 'staging'
  #    host: 'http://boorgle-staging.herokuapp.com/api/v1'
  #    clientId: 'boorgle-web-mobile'
  #    oauthEndpoint: 'http://boorgle-staging.herokuapp.com/oauth/'
  #    oauthRedirectUri: 'http://m.boorgle.com'

else
  # Production
  Config =
    env: 'production'
    host: 'http://www.boorgle.com/api/v1'
    clientId: 'boorgle-web-mobile'
    oauthEndpoint: 'http://www.boorgle.com/oauth/'
    oauthRedirectUri: 'http://m.boorgle.com'

Config['version'] = '2012-12-02'
module.exports = Config
