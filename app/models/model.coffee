Spine = require('spine')

class Model extends Spine.Model
  to_partial_path: ->
    @constructor._to_partial_path()

  @pluralLowerCase: ->
    @className.replace(/([a-z])([A-Z])/g, '$1_$2').toLowerCase()

  @_to_partial_path: ->
    ['views', @pluralLowerCase(), 'item'].join '/'

module.exports = Model
