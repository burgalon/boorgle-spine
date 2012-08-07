Spine = require('spine')
$       = Spine.$
List    = require('spine/lib/list')

Authorization = require('authorization')

# Models
FoundFriend = require('models/found_friend')
SearchFriend = require('models/search_friend')

# Controllers
UsersShow = require('controllers/users_show')
UsersList = require('controllers/users_list')

# Explore Tab - Found - Friend user detail
class FoundFriendShow extends UsersShow
  @configure FoundFriend
  tab: 'explore'

  back: ->
    @navigate('/found_friends', trans: 'left')

# Explore Tab - user list
class FoundFriendsList extends UsersList
  title: 'Explore'
  tab: 'explore'
  @configure FoundFriend, '/found_friends'
  collection_types: FoundFriend.collection_types
  search_collection_types: SearchFriend.collection_types
  events:
    'tap .item': 'click'
    'input input': 'search'
  elements:
    '.found-panel': 'foundPanel'
    '.search-panel': 'searchPanel'

  constructor: ->
    super

    # Set handles for sub-lists in the view
    for key in @collection_types
      @elements['.'+key] = key

    for key in @search_collection_types
      @elements['.search-'+key] = 'search_' + key

    @html require('views/found_friends_list')(this)

    # Initialize list sub-views for each collection of users
    for key in @collection_types
      @[key+'List'] = new List
            el: @[key]
            template: require(FoundFriend[key]._to_partial_path())

    # Initialize search list sub-views for each collection of users
    for key in @search_collection_types
      @[key+'SearchList'] = new List
        el: @['search_' + key]
        template: require(SearchFriend[key]._to_partial_path())

    SearchFriend.bind 'refresh change', @renderSearch

    # Login button
    unless Authorization.is_loggedin()
      @addButton('Login', ->
        @navigate('/user/edit', trans: 'left')
      ).addClass('right')

  # Renders sub-views
  render: =>
    for key in @collection_types
      @[key+'List'].render(FoundFriend[key].all())

  renderSearch: =>
    for key in @search_collection_types
      @[key+'SearchList'].render(SearchFriend[key].all())

  search: (e) ->
    element = $(e.currentTarget)
    value = element.val()

    # Toggle between search panel and explore recommendations
    if value
      SearchFriend.fetch(value)
      if !@searchPanel.hasClass('active')
        @searchPanel.addClass('active')
        @foundPanel.removeClass('active')
    else
      if @searchPanel.hasClass('active')
        @searchPanel.removeClass('active')
        @foundPanel.addClass('active')

# Explore Tab
class FoundFriends extends Spine.Controller
  tab: 'explore'

  constructor: ->
    super

    @list = new FoundFriendsList
    @show = new FoundFriendShow

    @routes
      '/found_friends/:id': (params) -> @show.active(params)
      '/found_friends': (params) -> @list.active(params)

module.exports = FoundFriends