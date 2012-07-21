Spine = require('spine')

class User extends Spine.Model
  @configure 'User', 'email', 'first_name', 'last_name', 'company', 'title', 'website', 'birthday', 'street', 'apartment', 'zipcode', 'city', 'region', 'country', 'groups', 'location', 'picture'
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
    region_or_country = if @is_us() then @region else @country
    @format(@city, @format(@region, @zipcode), region_or_country)



module.exports = User