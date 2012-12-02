Spine = require('spine')
App = require('index')

# Models
User = require('./user')

class MyUser extends User
  @configure 'MyUser'
  @extend Spine.Model.Ajax

  @url: ->
    Spine.Model.host + "/user"

  url: ->
    Spine.Model.host + "/user"

  # For UsersShow which uses find with id=undefined
  @find: ->
    @first()

  validate: ->
    for fieldName in ['email', 'first_name', 'last_name', 'zipcode', 'phones']
      return "Missing #{fieldName}" unless this[fieldName]

module.exports = MyUser