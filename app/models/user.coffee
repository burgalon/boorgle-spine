Model = require('./model')

Authorization = require('authorization')

class User extends Model
  @configure 'User', 'email', 'first_name', 'last_name', 'company', 'title', 'website', 'birthday', 'street', 'apartment', 'zipcode', 'city', 'region', 'country', 'groups', 'location', 'picture', 'phones'
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
    region_or_country = if @is_us() then null else @country
    @format(@street, @apartment, @city, @format(@region, @zipcode), region_or_country)

  picture_url: ->
    ret = @picture
    ret+='?oauth_token='+ Authorization.getToken() if ret.match('localhost|boorgle')
    ret

  # For some reason it seems like 'clear' is not a default
  # This is important when refreshing an empty AJAX response, and the result doesn't clear unless clear: true is specified
  @refresh: (values, options)->
    super(values, $.extend(options, clear: true))

module.exports = User