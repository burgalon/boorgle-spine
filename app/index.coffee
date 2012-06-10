require('lib/setup')

Spine   = require('spine')
{Stage} = require('spine.mobile')

Authorization = require('authorization')

# Models
FoundFriend = require('models/found_friend')
MyUser = require('models/my_user')

# Controllers
FoundFriends = require('controllers/found_friends')
UserEdit = require('controllers/user_edit')

Spine.Model.host = "http://localhost:3000/api/v1"

class App extends Stage.Global
  Authorization: Authorization

  constructor: ->
    super

    Authorization.setup()

    # Models
    FoundFriend.fetch()
    MyUser.fetch() if Authorization.is_loggedin()

    # Controllers
    @user_edit = new UserEdit
    @found_friends = new FoundFriends

    # General initializations
    Spine.Route.setup()#shim:true)
#    @navigate '/found_friends'
#    @navigate '/user/edit'
    @navigate '/user/edit/show' unless Spine.Route.change()

    @addTab('Explore', -> @navigate '/found_friends')
    @addTab('Synched', -> @navigate '/found_friends')
    @addTab('Account', -> @navigate '/user/edit/show')


  addTab: (text, callback) ->
    callback = @[callback] if typeof callback is 'string'
    button = $('<button />').text(text)
    button.tap(@proxy(callback))
    @footer.append(button)
    button

module.exports = App