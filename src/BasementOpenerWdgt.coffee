class BasementOpenerWdgt extends IconicDesktopSystemLinkWdgt

  @augmentWith HighlightableMixin, @name

  color_hover: Color.create 90, 90, 90
  color_pressed: Color.GRAY
  color_normal: Color.BLACK

  _acceptsDrops: true

  constructor: ->
    super "Basement", new GenericShortcutIconWdgt new BasementIconWdgt
    @target = world.basementWdgt
    @rawSetExtent new Point 75, 75

  iHaveBeenAddedTo: (whereTo, beingDropped) ->
    super
    if whereTo == world and !@userMovedThisFromComputedPosition
      @fullMoveTo world.bottomRight().subtract @extent().add world.desktopSidesPadding

  justDropped: (whereIn) ->
    super
    if whereIn == world
      @userMovedThisFromComputedPosition = true


  mouseClickLeft: (arg1, arg2, arg3, arg4, arg5, arg6, arg7, doubleClickInvocation, arg9) ->
    if doubleClickInvocation
      return

    if @target.isOrphan()
      @target.unCollapse()
      windowedBasementWdgt = new WindowWdgt nil, nil, @target
      world.add windowedBasementWdgt
      windowedBasementWdgt.rawSetExtent new Point 460, 400
      windowedBasementWdgt.fullRawMoveTo new Point 140, 90
      windowedBasementWdgt.rememberFractionalSituationInHoldingPanel()
      BasementInfoWdgt.createNextTo windowedBasementWdgt
    else
      # if the basement is not an orphan, then it's
      # visible somewhere and it's in a window
      @target.parent.spawnNextTo @
      @target.parent.rememberFractionalSituationInHoldingPanel()


  reactToDropOf: (droppedWidget) ->
    @target.scrollPanel.contents.addInPseudoRandomPosition droppedWidget

  rejectsBeingDropped: ->
    true