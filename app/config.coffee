if document.location.href.match(/localhost|192./)
  # Development
  Config =
    env: 'development'
    host: 'http://localhost:3000/api/v1'
    clientId: 'boorgle-iphone-localhost'
    oauthEndpoint: 'http://localhost:3000/oauth/'

#  # Development against production
#  Config =
#    env: 'development'
#    host: 'http://www.boorgle.com/api/v1'
#    clientId: 'boorgle-iphone-localhost'
#    oauthEndpoint: 'http://www.boorgle.com/oauth/'
else
  # Production
  Config =
    env: 'production'
    host: 'http://www.boorgle.com/api/v1'
    clientId: 'boorgle-iphone'
    oauthEndpoint: 'http://www.boorgle.com/oauth/'

module.exports = Config