# World-wide preferences and settings ///////////////////////////////////

# Contains all possible preferences and settings for a World.
# So it's World-wide values.
# It belongs to a world, each world may have different settings.
# this comment below is needed to figure out dependencies between classes

# REQUIRES globalFunctions
# REQUIRES DeepCopierMixin

class PreferencesAndSettings

  @augmentWith DeepCopierMixin

  @INPUT_MODE_MOUSE: 0
  @INPUT_MODE_TOUCH: 1

  # all these properties can be modified
  # by the input mode.
  inputMode: nil
  minimumFontHeight: nil
  menuFontName: nil
  menuFontSize: nil
  bubbleHelpFontSize: nil
  prompterFontName: nil
  prompterFontSize: nil
  prompterSliderSize: nil
  handleSize: nil
  scrollBarsThickness: nil

  wheelScaleX: 1
  wheelScaleY: 1
  wheelScaleZ: 1
  invertWheelX: true
  invertWheelY: true
  invertWheelZ: true

  useSliderForInput: nil
  useVirtualKeyboard: nil
  isTouchDevice: nil
  rasterizeSVGs: nil
  isFlat: nil
  grabDragThreshold: 7

  # decimalFloatFiguresOfFontSizeGranularity allows you to go into sub-points
  # in the font size. This is so the resizing of the
  # text is less "jumpy".
  # "1" seems to be perfect in terms of jumpiness,
  # but obviously this routine gets quite a bit more
  # expensive.
  @decimalFloatFiguresOfFontSizeGranularity: 0

  constructor: ->
    @setMouseInputMode()
    console.log("constructing PreferencesAndSettings")

  toggleInputMode: ->
    if @inputMode == PreferencesAndSettings.INPUT_MODE_MOUSE
      @setTouchInputMode()
    else
      @setMouseInputMode()

  setMouseInputMode: ->
    @inputMode = PreferencesAndSettings.INPUT_MODE_MOUSE
    @minimumFontHeight = getMinimumFontHeight() # browser settings
    @menuFontName = "sans-serif"
    @menuFontSize = 12
    @bubbleHelpFontSize = 10
    @prompterFontName = "sans-serif"
    @prompterFontSize = 12
    @prompterSliderSize = 10

    # handle and scrollbar should ideally be the
    # same size because they often show next to
    # each other
    @handleSize = 15
    @scrollBarsThickness = 10

    @wheelScaleX = 1
    @wheelScaleY = 1
    @wheelScaleZ = 1
    @invertWheelX = true
    @invertWheelY = true
    @invertWheelZ = true

    @useSliderForInput = false
    @useVirtualKeyboard = true
    @isTouchDevice = false # turned on by touch events, don't set
    @rasterizeSVGs = false
    @isFlat = false

  setTouchInputMode: ->
    @inputMode = PreferencesAndSettings.INPUT_MODE_TOUCH
    @minimumFontHeight = getMinimumFontHeight()
    @menuFontName = "sans-serif"
    @menuFontSize = 24
    @bubbleHelpFontSize = 18
    @prompterFontName = "sans-serif"
    @prompterFontSize = 24
    @prompterSliderSize = 20

    # handle and scrollbar should ideally be the
    # same size because they often show next to
    # each other
    @handleSize = 26
    @scrollBarsThickness = 24

    @wheelScaleX = 1
    @wheelScaleY = 1
    @wheelScaleZ = 1
    @invertWheelX = true
    @invertWheelY = true
    @invertWheelZ = true

    @useSliderForInput = true
    @useVirtualKeyboard = true
    @isTouchDevice = false
    @rasterizeSVGs = false
    @isFlat = false

