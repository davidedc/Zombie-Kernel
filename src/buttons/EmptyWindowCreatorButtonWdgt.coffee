# REQUIRES HighlightableMixin
# REQUIRES ParentStainerMixin

class EmptyWindowCreatorButtonWdgt extends Widget

  @augmentWith HighlightableMixin, @name
  @augmentWith ParentStainerMixin, @name

  color_hover: new Color 90, 90, 90
  color_pressed: new Color 128, 128, 128
  color_normal: new Color 230, 230, 230

  constructor: ->
    super
    @appearance = new EmptyWindowIconAppearance @, WorldMorph.preferencesAndSettings.iconDarkLineColor
    @actionableAsThumbnail = true
    @editorContentPropertyChangerButton = true
    @toolTipMessage = "link"

  grabbedWidgetSwitcheroo: ->
    switcherooWm = new WindowWdgt nil, nil, nil, true, true
    switcherooWm.setExtent new Point 200, 200
    return switcherooWm

  # otherwise the glassbox bottom will answer on drags
  # and will just pick up the button and move it,
  # while we want the drag to create a textbox
  grabsToParentWhenDragged: ->
    false
