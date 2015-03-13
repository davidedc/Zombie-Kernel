# TriggerMorph ////////////////////////////////////////////////////////

# I provide basic button functionality.
# All menu items and buttons are TriggerMorphs.
# The handling of the triggering is not
# trivial, as the concepts of
# dataSourceMorphForTarget, target and action
# are used - see comments.
# REQUIRES BackingStoreMixin

class TriggerMorph extends Morph
  @augmentWith BackingStoreMixin

  target: null
  action: null
  dataSourceMorphForTarget: null
  morphEnv: null
  label: null
  labelString: null
  labelColor: null
  labelBold: null
  labelItalic: null
  doubleClickAction: null
  argumentToAction1: null
  argumentToAction2: null
  hint: null
  fontSize: null
  fontStyle: null
  # careful: this Color object is shared with all the instances of this class.
  # if you modify it, then all the objects will get the change
  # but if you replace it with a new Color, then that will only affect the
  # specific object instance. Same behaviour as with arrays.
  # see: https://github.com/jashkenas/coffee-script/issues/2501#issuecomment-7865333
  highlightColor: new Color(192, 192, 192)
  highlightImage: null
  # careful: this Color object is shared with all the instances of this class.
  # if you modify it, then all the objects will get the change
  # but if you replace it with a new Color, then that will only affect the
  # specific object instance. Same behaviour as with arrays.
  # see: https://github.com/jashkenas/coffee-script/issues/2501#issuecomment-7865333
  pressColor: new Color(128, 128, 128)
  normalImage: null
  pressImage: null
  centered: false

  constructor: (
      @target = null,
      @action = null,
      @labelString = null,
      fontSize,
      fontStyle,
      @centered = false,
      @dataSourceMorphForTarget = null,
      @morphEnv,
      @hint = null,
      labelColor,
      @labelBold = false,
      @labelItalic = false,
      @doubleClickAction = null,
      @argumentToAction1 = null,
      @argumentToAction2 = null
      ) ->

    # additional properties:
    @fontSize = fontSize or WorldMorph.preferencesAndSettings.menuFontSize
    @fontStyle = fontStyle or "sans-serif"
    @labelColor = labelColor or new Color(0, 0, 0)

    super()

    #@color = new Color(255, 152, 152)
    @color = new Color(255, 255, 255)
    if @labelString?
      @layoutSubmorphs()
  
  layoutSubmorphs: ->
    if not @label?
      @createLabel()
    if @centered
      @label.setPosition @center().subtract(@label.extent().floorDivideBy(2))

  setLabel: (@labelString) ->
    # just recreated the label
    # from scratch
    if @label?
      @label = @label.destroy()
    @layoutSubmorphs()

  alignCenter: ->
    if !@centered
      @centered = true
      @layoutSubmorphs()

  alignLeft: ->
    if @centered
      @centered = false
      @layoutSubmorphs()
  
  # no changes of position or extent
  updateBackingStore: ->
    extent = @extent()
    @normalImage = newCanvas(extent.scaleBy pixelRatio)
    context = @normalImage.getContext("2d")
    context.scale pixelRatio, pixelRatio
    context.fillStyle = @color.toString()
    context.fillRect 0, 0, extent.x, extent.y
    @highlightImage = newCanvas(extent.scaleBy pixelRatio)
    context = @highlightImage.getContext("2d")
    context.scale pixelRatio, pixelRatio
    context.fillStyle = @highlightColor.toString()
    context.fillRect 0, 0, extent.x, extent.y
    @pressImage = newCanvas(extent.scaleBy pixelRatio)
    context = @pressImage.getContext("2d")
    context.scale pixelRatio, pixelRatio
    context.fillStyle = @pressColor.toString()
    context.fillRect 0, 0, extent.x, extent.y
    @image = @normalImage
  
  createLabel: ->
    # bold
    # italic
    # numeric
    # shadow offset
    # shadow color
    @label = new StringMorph(
      @labelString or "",
      @fontSize,
      @fontStyle,
      @labelBold,
      @labelItalic,
      false,
      @labelColor      
    )
    @add @label
    
  
  # TriggerMorph action:
  trigger: ->
    if @action
      if typeof @action is "function"
        console.log "trigger invoked with function"
        debugger
        @action.call @target, @dataSourceMorphForTarget
      else # assume it's a String
        @target[@action].call @target, @dataSourceMorphForTarget, @morphEnv, @argumentToAction1, @argumentToAction2

  triggerDoubleClick: ->
    # same as trigger() but use doubleClickAction instead of action property
    # note that specifying a doubleClickAction is optional
    return  unless @doubleClickAction
    if typeof @target is "function"
      if typeof @doubleClickAction is "function"
        @target.call @dataSourceMorphForTarget, @doubleClickAction.call(), this
      else
        @target.call @dataSourceMorphForTarget, @doubleClickAction, this
    else
      if typeof @doubleClickAction is "function"
        @doubleClickAction.call @target
      else # assume it's a String
        @target[@doubleClickAction]()  
  
  # TriggerMorph events:
  mouseEnter: ->
    @image = @highlightImage
    @changed()
    @startCountdownForBubbleHelp @hint  if @hint
  
  mouseLeave: ->
    @image = @normalImage
    @changed()
    @world().hand.destroyTemporaries()  if @hint
  
  mouseDownLeft: ->
    @image = @pressImage
    @changed()
  
  mouseClickLeft: ->
    super()
    @image = @highlightImage
    @changed()
    @trigger()

  mouseDoubleClick: ->
    @triggerDoubleClick()

  # Disable dragging compound Morphs by Triggers
  # User can still move the trigger itself though
  # (it it's unlocked)
  rootForGrab: ->
    if @isDraggable
      return super()
    null
  
  # TriggerMorph bubble help:
  startCountdownForBubbleHelp: (contents) ->
    SpeechBubbleMorph.createInAWhileIfHandStillContainedInMorph @, contents
