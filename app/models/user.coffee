Spine = require('spine')

class User extends Spine.Model
  @extend Spine.Model.Ajax

  @configure 'User', 'email', 'first_name', 'last_name', 'company', 'title', 'website', 'birthday', 'street', 'apartment', 'zipcode', 'city', 'region', 'country', 'groups', 'location'

  name: ->
    [@first_name, @last_name].join(' ')

  is_us : ->
    @country=='US'

  formatted_address : ->
    [@street, @apartment].join(', ')

  formatted_address1 : ->
    [@street, @apartment].join(', ')

  formatted_address2 : ->
    [@city, [@region, @zipcode].join(' '), @is_us() ? nil : country].join(', ')

  @url: "/found_friends/1"


module.exports = User