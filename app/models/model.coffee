Spine = require('spine')

class Model extends Spine.Model
  to_partial_path: ->
    @constructor._to_partial_path()

  @pluralLowerCase: ->
    @className.replace(/([a-z])([A-Z])/g, '$1_$2').toLowerCase()+'s'

  @_to_partial_path: ->
    ['views', @pluralLowerCase(), 'item'].join '/'

  # For some reason it seems like 'clear' is not a default
  # This is important when refreshing an empty AJAX response, and the result doesn't clear unless clear: true is specified
  @refresh: (values, options)->
    super(values, $.extend(options, clear: true))

module.exports = Model
