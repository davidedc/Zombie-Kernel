# InspectorMorph //////////////////////////////////////////////////////

class InspectorMorph extends BoxMorph
  constructor: (target) ->
    @init target

# InspectorMorph instance creation:
InspectorMorph::init = (target) ->
  
  # additional properties:
  @target = target
  @currentProperty = null
  @showing = "attributes"
  @markOwnProperties = false
  
  # initialize inherited properties:
  super()
  
  # override inherited properties:
  @silentSetExtent new Point(MorphicPreferences.handleSize * 20, MorphicPreferences.handleSize * 20 * 2 / 3)
  @isDraggable = true
  @border = 1
  @edge = 5
  @color = new Color(60, 60, 60)
  @borderColor = new Color(95, 95, 95)
  @drawNew()
  
  # panes:
  @label = null
  @list = null
  @detail = null
  @work = null
  @buttonInspect = null
  @buttonClose = null
  @buttonSubset = null
  @buttonEdit = null
  @resizer = null
  @buildPanes()  if @target

InspectorMorph::setTarget = (target) ->
  @target = target
  @currentProperty = null
  @buildPanes()

InspectorMorph::buildPanes = ->
  attribs = []
  property = undefined
  myself = this
  ctrl = undefined
  ev = undefined
  
  # remove existing panes
  @children.forEach (m) ->
    # keep work pane around
    m.destroy()  if m isnt @work

  @children = []
  
  # label
  @label = new TextMorph(@target.toString())
  @label.fontSize = MorphicPreferences.menuFontSize
  @label.isBold = true
  @label.color = new Color(255, 255, 255)
  @label.drawNew()
  @add @label
  
  # properties list
  for property of @target
    # dummy condition, to be refined
    attribs.push property  if property
  if @showing is "attributes"
    attribs = attribs.filter((prop) ->
      typeof myself.target[prop] isnt "function"
    )
  else if @showing is "methods"
    attribs = attribs.filter((prop) ->
      typeof myself.target[prop] is "function"
    )
  # otherwise show all properties
  # label getter
  # format list
  # format element: [color, predicate(element]
  @list = new ListMorph((if @target instanceof Array then attribs else attribs.sort()), null, (if @markOwnProperties then [[new Color(0, 0, 180), (element) ->
    myself.target.hasOwnProperty element
  ]] else null))
  @list.action = (selected) ->
    val = undefined
    txt = undefined
    cnts = undefined
    val = myself.target[selected]
    myself.currentProperty = val
    if val is null
      txt = "NULL"
    else if isString(val)
      txt = val
    else
      txt = val.toString()
    cnts = new TextMorph(txt)
    cnts.isEditable = true
    cnts.enableSelecting()
    cnts.setReceiver myself.target
    myself.detail.setContents cnts

  @list.hBar.alpha = 0.6
  @list.vBar.alpha = 0.6
  @add @list
  
  # details pane
  @detail = new ScrollFrameMorph()
  @detail.acceptsDrops = false
  @detail.contents.acceptsDrops = false
  @detail.isTextLineWrapping = true
  @detail.color = new Color(255, 255, 255)
  @detail.hBar.alpha = 0.6
  @detail.vBar.alpha = 0.6
  ctrl = new TextMorph("")
  ctrl.isEditable = true
  ctrl.enableSelecting()
  ctrl.setReceiver @target
  @detail.setContents ctrl
  @add @detail
  
  # work ('evaluation') pane
  # don't refresh the work pane if it already exists
  if @work is null
    @work = new ScrollFrameMorph()
    @work.acceptsDrops = false
    @work.contents.acceptsDrops = false
    @work.isTextLineWrapping = true
    @work.color = new Color(255, 255, 255)
    @work.hBar.alpha = 0.6
    @work.vBar.alpha = 0.6
    ev = new TextMorph("")
    ev.isEditable = true
    ev.enableSelecting()
    ev.setReceiver @target
    @work.setContents ev
  @add @work
  
  # properties button
  @buttonSubset = new TriggerMorph()
  @buttonSubset.labelString = "show..."
  @buttonSubset.action = ->
    menu = undefined
    menu = new MenuMorph()
    menu.addItem "attributes", ->
      myself.showing = "attributes"
      myself.buildPanes()

    menu.addItem "methods", ->
      myself.showing = "methods"
      myself.buildPanes()

    menu.addItem "all", ->
      myself.showing = "all"
      myself.buildPanes()

    menu.addLine()
    menu.addItem ((if myself.markOwnProperties then "un-mark own" else "mark own")), (->
      myself.markOwnProperties = not myself.markOwnProperties
      myself.buildPanes()
    ), "highlight\n'own' properties"
    menu.popUpAtHand myself.world()

  @add @buttonSubset
  
  # inspect button
  @buttonInspect = new TriggerMorph()
  @buttonInspect.labelString = "inspect..."
  @buttonInspect.action = ->
    menu = undefined
    world = undefined
    inspector = undefined
    if isObject(myself.currentProperty)
      menu = new MenuMorph()
      menu.addItem "in new inspector...", ->
        world = myself.world()
        inspector = new InspectorMorph(myself.currentProperty)
        inspector.setPosition world.hand.position()
        inspector.keepWithin world
        world.add inspector
        inspector.changed()

      menu.addItem "here...", ->
        myself.setTarget myself.currentProperty

      menu.popUpAtHand myself.world()
    else
      myself.inform ((if myself.currentProperty is null then "null" else typeof myself.currentProperty)) + "\nis not inspectable"

  @add @buttonInspect
  
  # edit button
  @buttonEdit = new TriggerMorph()
  @buttonEdit.labelString = "edit..."
  @buttonEdit.action = ->
    menu = undefined
    menu = new MenuMorph(myself)
    menu.addItem "save", "save", "accept changes"
    menu.addLine()
    menu.addItem "add property...", "addProperty"
    menu.addItem "rename...", "renameProperty"
    menu.addItem "remove...", "removeProperty"
    menu.popUpAtHand myself.world()

  @add @buttonEdit
  
  # close button
  @buttonClose = new TriggerMorph()
  @buttonClose.labelString = "close"
  @buttonClose.action = ->
    myself.destroy()

  @add @buttonClose
  
  # resizer
  @resizer = new HandleMorph(this, 150, 100, @edge, @edge)
  
  # update layout
  @fixLayout()

InspectorMorph::fixLayout = ->
  x = undefined
  y = undefined
  r = undefined
  b = undefined
  w = undefined
  h = undefined
  Morph::trackChanges = false
  
  # label
  x = @left() + @edge
  y = @top() + @edge
  r = @right() - @edge
  w = r - x
  @label.setPosition new Point(x, y)
  @label.setWidth w
  if @label.height() > (@height() - 50)
    @silentSetHeight @label.height() + 50
    @drawNew()
    @changed()
    @resizer.drawNew()
  
  # list
  y = @label.bottom() + 2
  w = Math.min(Math.floor(@width() / 3), @list.listContents.width())
  w -= @edge
  b = @bottom() - (2 * @edge) - MorphicPreferences.handleSize
  h = b - y
  @list.setPosition new Point(x, y)
  @list.setExtent new Point(w, h)
  
  # detail
  x = @list.right() + @edge
  r = @right() - @edge
  w = r - x
  @detail.setPosition new Point(x, y)
  @detail.setExtent new Point(w, (h * 2 / 3) - @edge)
  
  # work
  y = @detail.bottom() + @edge
  @work.setPosition new Point(x, y)
  @work.setExtent new Point(w, h / 3)
  
  # properties button
  x = @list.left()
  y = @list.bottom() + @edge
  w = @list.width()
  h = MorphicPreferences.handleSize
  @buttonSubset.setPosition new Point(x, y)
  @buttonSubset.setExtent new Point(w, h)
  
  # inspect button
  x = @detail.left()
  w = @detail.width() - @edge - MorphicPreferences.handleSize
  w = w / 3 - @edge / 3
  @buttonInspect.setPosition new Point(x, y)
  @buttonInspect.setExtent new Point(w, h)
  
  # edit button
  x = @buttonInspect.right() + @edge
  @buttonEdit.setPosition new Point(x, y)
  @buttonEdit.setExtent new Point(w, h)
  
  # close button
  x = @buttonEdit.right() + @edge
  r = @detail.right() - @edge - MorphicPreferences.handleSize
  w = r - x
  @buttonClose.setPosition new Point(x, y)
  @buttonClose.setExtent new Point(w, h)
  Morph::trackChanges = true
  @changed()

InspectorMorph::setExtent = (aPoint) ->
  super aPoint
  @fixLayout()


#InspectorMorph editing ops:
InspectorMorph::save = ->
  txt = @detail.contents.children[0].text.toString()
  prop = @list.selected
  try
    
    # this.target[prop] = evaluate(txt);
    @target.evaluateString "this." + prop + " = " + txt
    if @target.drawNew
      @target.changed()
      @target.drawNew()
      @target.changed()
  catch err
    @inform err

InspectorMorph::addProperty = ->
  myself = this
  @prompt "new property name:", ((prop) ->
    if prop
      myself.target[prop] = null
      myself.buildPanes()
      if myself.target.drawNew
        myself.target.changed()
        myself.target.drawNew()
        myself.target.changed()
  ), this, "property" # Chrome cannot handle empty strings (others do)

InspectorMorph::renameProperty = ->
  myself = this
  propertyName = @list.selected
  @prompt "property name:", ((prop) ->
    try
      delete (myself.target[propertyName])

      myself.target[prop] = myself.currentProperty
    catch err
      myself.inform err
    myself.buildPanes()
    if myself.target.drawNew
      myself.target.changed()
      myself.target.drawNew()
      myself.target.changed()
  ), this, propertyName

InspectorMorph::removeProperty = ->
  prop = @list.selected
  try
    delete (@target[prop])

    @currentProperty = null
    @buildPanes()
    if @target.drawNew
      @target.changed()
      @target.drawNew()
      @target.changed()
  catch err
    @inform err
