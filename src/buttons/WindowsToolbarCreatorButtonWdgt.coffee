# REQUIRES HighlightableMixin
# REQUIRES ParentStainerMixin

class WindowsToolbarCreatorButtonWdgt extends Widget

  @augmentWith HighlightableMixin, @name
  @augmentWith ParentStainerMixin, @name

  color_hover: new Color 90, 90, 90
  color_pressed: new Color 128, 128, 128
  color_normal: new Color 230, 230, 230

  constructor: ->
    super
    @appearance = new WindowsToolbarIconAppearance @, WorldMorph.preferencesAndSettings.iconDarkLineColor
    @actionableAsThumbnail = true
    @editorContentPropertyChangerButton = true
    @toolTipMessage = "many types of\npre-made windows"

  grabbedWidgetSwitcheroo: ->

    toolsPanel = new ScrollPanelWdgt new ToolPanelWdgt()

    toolsPanel.addMany [
      new EmptyWindowCreatorButtonWdgt()
      new WindowWithPanelCreatorButtonWdgt()
      new WindowWithScrollPanelCreatorButtonWdgt()
      new ElasticWindowCreatorButtonWdgt()
    ]

    toolsPanel.disableDragsDropsAndEditing()

    switcherooWm = new WindowWdgt nil, nil, toolsPanel
    switcherooWm.fullRawMoveTo new Point 90, Math.floor((world.height()-192)/2)
    switcherooWm.fullRawMoveWithin world
    world.add switcherooWm
    switcherooWm.rawSetExtent new Point 61, 192

    return switcherooWm

  # otherwise the glassbox bottom will answer on drags
  # and will just pick up the button and move it,
  # while we want the drag to create a textbox
  grabsToParentWhenDragged: ->
    false
