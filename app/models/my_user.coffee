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

module.exports = MyUser