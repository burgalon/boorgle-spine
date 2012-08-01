Spine = require('spine')
App = require('index')

# Models
User = require('./user')

# This is a user that was found from GMail, and is NOT a Boorgle user
# This model user can only be 'invited' but not directly 'added'
class GmailUser extends User
  @configure 'GmailUser'

module.exports = GmailUser