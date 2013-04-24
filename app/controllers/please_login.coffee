Spine = require('spine')
Authorization = require('/authorization')
BasePanel = require('./base_panel')

class PleaseLogin extends BasePanel
  className: 'please_login'
  events:
    'tap .gmail': 'gmailButton'
    'tap .signup': 'signupButton'
    'tap .login': 'loginButton'
    'touchstart .upper-pane': 'touchstart'
    'touchmove .upper-pane': 'touchmove'
    'touchend .upper-pane': 'touchend'
    'mousedown .upper-pane': 'touchstart'
    'mousemove .upper-pane': 'touchmove'
    'mouseup .upper-pane': 'touchend'

  elements:
    '#slides': 'slides'
    '.bullet': 'bullets'

  sliding: 0
  startClientX: 0
  startPixelOffset: 0
  pixelOffset: 0
  currentSlide: 0

  constructor: ->
    super
    @active @render

  render: =>
    @html require('views/users/please_login')()
    @slideCount = $('.slide').length
    @updateBullets()

  gmailButton: ->
    Authorization.connectGmail()

  signupButton: ->
    @navigate '/user/edit', trans: 'right'

  touchstart: (event) ->
    event = event.originalEvent.touches[0] if event.originalEvent.touches
    if @sliding == 0
      @sliding = 1
      @startClientX = event.clientX


  # http://mobile.smashingmagazine.com/2012/06/21/play-with-hardware-accelerated-css/
  touchmove: (event) ->
    event.preventDefault()
    if event.originalEvent.touches
      event = event.originalEvent.touches[0]
    deltaSlide = event.clientX - @startClientX

    if @sliding == 1 && deltaSlide != 0
      @sliding = 2
      @startPixelOffset = @pixelOffset

    if @sliding == 2
      touchPixelRatio = 1
      if (@currentSide == 0 && event.clientX > @startClientX) || (@currentSlide == @slideCount-1 && event.clientX < @startClientX)
        touchPixelRatio = 3
      @pixelOffset = @startPixelOffset + deltaSlide / touchPixelRatio
      @slides.css('-webkit-transform', 'translate3d(' + @pixelOffset + 'px,0,0)').removeClass()

  touchend: (e) ->
    if @sliding == 2
      @sliding = 0
      @currentSlide = if (@pixelOffset < @startPixelOffset) then (@currentSlide + 1) else (@currentSlide - 1)
      @currentSlide = Math.min(Math.max(@currentSlide, 0), @slideCount - 1)
      @pixelOffset = @currentSlide * -$(window).width()
      @log '@slideCount', @slideCount, @currentSlide, @pixelOffset
      $('#temp').remove()
      $('<style id="temp">#slides.animate{-webkit-transform:translate3d(' + @pixelOffset + 'px,0,0) !important}</style>').appendTo('head')
      @slides.addClass('animate').css('transform', '')
      @updateBullets()

  updateBullets: ->
    @log 'bullets', @bullets
    @bullets.removeClass('selected')
    $('.bullet:nth-child(' + (@currentSlide + 1) + ')', @el).addClass('selected')

  loginButton: ->
    @navigate '/user/login', trans: 'right'

module.exports = PleaseLogin