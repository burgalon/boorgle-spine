Spine = require('spine')
{Panel} = require('spine.mobile')

# Model
MyUser = require('models/my_user')

# Controllers
UsersShow = require('controllers/users_show')

class UserEditForm extends Panel
  elements:
    'form': 'form'

  events:
    'submit form': 'submit'

  className: 'users editView'

  constructor: ->
    super

    MyUser.bind('refresh change', @change)
    @active @change

    @addButton('Cancel', @back)
    @addButton('Save', @submit).addClass('right')

    @active @render

  render: =>
    if @item
      @html require('views/users/form')(@item)
    else
      @html require('views/users/please_login')()

  submit: (e) ->
    e.preventDefault()
    user = @item.fromForm(@form)
    @log "submit user - ", user
    if user.save()
      @navigate('/user/edit/show', trans: 'left')

  back: ->
    @navigate('/user/edit/show', trans: 'left')

  deactivate: ->
    super
    @form.blur()

  change: =>
    @item = MyUser.first()
    @render()

class MyUserShow extends UsersShow
  @configure MyUser

  add_buttons: ->
    @addButton('Edit', @back)
    @addButton('Log Out', @logout).addClass('right')

  back: ->
    @navigate('/user/edit', trans: 'right')

  logout: ->
    alert('TBD')

class UserEdit extends Spine.Controller
  constructor: ->
    super

    @form = new UserEditForm
    @show = new MyUserShow

    @routes
      '/user/edit/show': (params) -> @show.active(params)
      '/user/edit': (params) -> @form.active(params)

module.exports = UserEdit