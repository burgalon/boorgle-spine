Spine = require('spine')

class User extends Spine.Model
  @configure 'User', 'email', 'first_name', 'last_name', 'company', 'title', 'website', 'birthday', 'street', 'apartment', 'zipcode', 'city', 'region', 'country', 'groups', 'location'
  @extend Spine.Model.Ajax

  name: ->
    [@first_name, @last_name].join(' ')

  is_us : ->
    @country=='US'

  format: (args...) ->
    $.grep(args, (x) -> return x).join(', ')

  formatted_address : ->
    @format(@street, @apartment)

  formatted_address1 : ->
    @format(@street, @apartment)

  formatted_address2 : ->
    @format(@city, @format(@region, @zipcode), @is_us() ? nil : country)



module.exports = User