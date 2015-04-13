# Manages the controls of the System Tests
# e.g. all the links/buttons to trigger commands
# when recording tests such as
#  - start recording tests
#  - stop recording tests
#  - take screenshot
#  - save test files
#  - place the mouse over a morph with particular ID...


class SystemTestsControlPanelUpdater

  # Create the div where the controls will go
  # and make it float to the right of the canvas.
  # This requires tweaking the css of the canvas
  # as well.

  SystemTestsControlPanelDiv: null
  @SystemTestsControlPanelOutputConsoleDiv: null

  @resetWorldLink: null
  @tieAnimations: null
  @alignMorphIDs: null
  @hideGeometry: null
  @hideMorphContentExtracts: null
  @hideMorphIDs: null
  @takeScreenshot: null
  @checkNumnberOfItems: null
  @checkMenuEntriesInOrder: null
  @checkMenuEntriesNotInOrder: null
  @addTestComment: null
  @stopTestRec: null

  @highlightOnLink: (theElementName) ->
    theElement = document.getElementById(theElementName + "On")
    if theElement?
      theElement.style.backgroundColor = 'red'
    theElement = document.getElementById(theElementName + "Off")
    if theElement?
      theElement.style.backgroundColor = 'white'

  @highlightOffLink: (theElementName) ->
    theElement = document.getElementById(theElementName + "On")
    if theElement?
      theElement.style.backgroundColor = 'white'
    theElement = document.getElementById(theElementName + "Off")
    if theElement?
      theElement.style.backgroundColor = 'red'


  @addMessageToSystemTestsConsole: (theText) ->
    SystemTestsControlPanelUpdater.SystemTestsControlPanelOutputConsoleDiv.innerHTML = SystemTestsControlPanelUpdater.SystemTestsControlPanelOutputConsoleDiv.innerHTML + theText + "</br>";

  @addMessageToTestCommentsConsole: (theText) ->
    SystemTestsControlPanelUpdater.SystemTestsControlPanelTestCommentsOutputConsoleDiv.innerHTML = SystemTestsControlPanelUpdater.SystemTestsControlPanelTestCommentsOutputConsoleDiv.innerHTML + theText + "</br>";

  @blinkLink: (theId) ->
    theElement = document.getElementById(theId)

    if theElement?
        theElement.style.backgroundColor = 'red'
        setTimeout \
          ->
            theElement.style.backgroundColor = 'white'
          , 100
        setTimeout \
          ->
            theElement.style.backgroundColor = 'red'
          , 200
        setTimeout \
          ->
            theElement.style.backgroundColor = 'white'
          , 300


  addLink: (theText, theFunction) ->
    aTag = document.createElement("a")
    linkID = theText.replace(/[^a-zA-Z0-9]/g, "")
    aTag.id = linkID
    aTag.setAttribute "href", "#"
    aTag.innerHTML = theText
    aTag.onclick = theFunction
    @SystemTestsControlPanelDiv.appendChild aTag
    br = document.createElement('br')
    @SystemTestsControlPanelDiv.appendChild(br)
    return linkID

  addOnOffSwitchLink: (theText, onShortcut, offShortcut, onAction, offAction) ->
    #aLittleDiv = document.createElement("div")
    
    linkID = theText.replace(/[^a-zA-Z0-9]/g, "")
    aLittleSpan = document.createElement("span")
    aLittleSpan.innerHTML = theText + " "

    aLittleSpacerSpan = document.createElement("span")
    aLittleSpacerSpan.innerHTML = " "

    onLinkElement = document.createElement("a")
    onLinkElement.setAttribute "href", "#"
    onLinkElement.innerHTML = "on:"+onShortcut
    onLinkElement.id = linkID + "On"
    onLinkElement.onclick = onAction

    offLinkElement = document.createElement("a")
    offLinkElement.setAttribute "href", "#"
    offLinkElement.innerHTML = "off:"+offShortcut
    offLinkElement.id = linkID + "Off"
    offLinkElement.onclick = offAction

    @SystemTestsControlPanelDiv.appendChild aLittleSpan
    @SystemTestsControlPanelDiv.appendChild onLinkElement
    @SystemTestsControlPanelDiv.appendChild aLittleSpacerSpan
    @SystemTestsControlPanelDiv.appendChild offLinkElement

    br = document.createElement('br')
    @SystemTestsControlPanelDiv.appendChild(br);
    return linkID

  addOutputPanel: (nameOfPanel) ->
    SystemTestsControlPanelUpdater[nameOfPanel] = document.createElement('div')
    SystemTestsControlPanelUpdater[nameOfPanel].id = nameOfPanel
    SystemTestsControlPanelUpdater[nameOfPanel].style.cssText = 'height: 150px; border: 1px solid red; overflow: hidden; overflow-y: scroll;'
    document.body.appendChild(SystemTestsControlPanelUpdater[nameOfPanel])

  constructor: ->
    @SystemTestsControlPanelDiv = document.createElement('div')
    @SystemTestsControlPanelDiv.id = "SystemTestsControlPanel"
    @SystemTestsControlPanelDiv.style.cssText = 'border: 1px solid green; overflow: hidden; font-size: x-small;'
    document.body.appendChild(@SystemTestsControlPanelDiv)

    @addOutputPanel "SystemTestsControlPanelOutputConsoleDiv"
    @addOutputPanel "SystemTestsControlPanelTestCommentsOutputConsoleDiv"

    theCanvasDiv = document.getElementById('world')
    # one of these is for IE and the other one
    # for everybody else
    theCanvasDiv.style.styleFloat = 'left';
    theCanvasDiv.style.cssFloat = 'left';

    # The spirit of these links is that it would
    # be really inconvenient to trigger
    # these commands using menus during the test.
    # For example it would be inconvenient to stop
    # the tests recording by selecting the command
    # via e menu: a bunch of mouse actions would be
    # recorded, exposing as well to the risk of the
    # menu items changing.
    SystemTestsControlPanelUpdater.resetWorldLink = @addLink "alt+d: reset world", (-> window.world.systemTestsRecorderAndPlayer.resetWorld())
    SystemTestsControlPanelUpdater.tieAnimations = @addOnOffSwitchLink "tie animations to test step", "alt+e", "alt+u", (-> window.world.systemTestsRecorderAndPlayer.turnOnAnimationsPacingControl()), (-> window.world.systemTestsRecorderAndPlayer.turnOffAnimationsPacingControl())
    SystemTestsControlPanelUpdater.alignMorphIDs = @addOnOffSwitchLink "periodically align Morph IDs", "-", "-", (-> window.world.systemTestsRecorderAndPlayer.turnOnAlignmentOfMorphIDsMechanism()), (-> window.world.systemTestsRecorderAndPlayer.turnOffAlignmentOfMorphIDsMechanism())
    SystemTestsControlPanelUpdater.hideGeometry = @addOnOffSwitchLink "hide Morph geometry in labels", "-", "-", (-> window.world.systemTestsRecorderAndPlayer.turnOnHidingOfMorphsGeometryInfoInLabels()), (-> window.world.systemTestsRecorderAndPlayer.turnOffHidingOfMorphsGeometryInfoInLabels())

    SystemTestsControlPanelUpdater.hideMorphContentExtracts = @addOnOffSwitchLink "hide Morph content extract in labels", "-", "-", (-> window.world.systemTestsRecorderAndPlayer.turnOnHidingOfMorphsContentExtractInLabels()), (-> window.world.systemTestsRecorderAndPlayer.turnOffHidingOfMorphsContentExtractInLabels())

    SystemTestsControlPanelUpdater.hideMorphIDs = @addOnOffSwitchLink "hide Morph number ID in labels", "-", "-", (-> window.world.systemTestsRecorderAndPlayer.turnOnHidingOfMorphsNumberIDInLabels()), (-> window.world.systemTestsRecorderAndPlayer.turnOffHidingOfMorphsNumberIDInLabels())

    SystemTestsControlPanelUpdater.takeScreenshot = @addLink "alt+c: take screenshot", (-> window.world.systemTestsRecorderAndPlayer.takeScreenshot())
    SystemTestsControlPanelUpdater.checkNumnberOfItems = @addLink "alt+k: check number of items in menu", (-> window.world.systemTestsRecorderAndPlayer.checkNumberOfItemsInMenu())
    SystemTestsControlPanelUpdater.checkMenuEntriesInOrder = @addLink "alt+a: check menu entries (in order)", (-> window.world.systemTestsRecorderAndPlayer.checkStringsOfItemsInMenuOrderImportant())
    SystemTestsControlPanelUpdater.checkMenuEntriesNotInOrder = @addLink "alt+z: check menu entries (any order)", (-> window.world.systemTestsRecorderAndPlayer.checkStringsOfItemsInMenuOrderUnimportant())
    SystemTestsControlPanelUpdater.addTestComment = @addLink "alt+m: add test comment", (-> window.world.systemTestsRecorderAndPlayer.addTestComment())
    SystemTestsControlPanelUpdater.stopTestRec = @addLink "alt+t: stop test recording", (-> window.world.systemTestsRecorderAndPlayer.stopTestRecording())


    # add the div with the fake mouse pointer
    mousePointerIndicator = document.createElement('div')
    mousePointerIndicator.id = "mousePointerIndicator"
    mousePointerIndicator.style.cssText = 'position: absolute; display:none;'
    document.body.appendChild(mousePointerIndicator)
    elem = document.createElement("img");
    elem.setAttribute("src", "icons/xPointerImage.png");
    document.getElementById("mousePointerIndicator").appendChild(elem);

    # add the div highlighting the state of the
    # left mouse button
    leftMouseButtonIndicator = document.createElement('div')
    leftMouseButtonIndicator.id = "leftMouseButtonIndicator"
    leftMouseButtonIndicator.style.cssText = 'position: absolute; left: 10px; top: 45px;'
    document.body.appendChild(leftMouseButtonIndicator)
    elem = document.createElement("img");
    elem.setAttribute("src", "icons/leftButtonPressed.png");
    document.getElementById("leftMouseButtonIndicator").appendChild(elem);
    fade('leftMouseButtonIndicator', 1, 0, 10, new Date().getTime());

    # add the div highlighting the state of the
    # right mouse button
    rightMouseButtonIndicator = document.createElement('div')
    rightMouseButtonIndicator.id = "rightMouseButtonIndicator"
    rightMouseButtonIndicator.style.cssText = 'position: absolute; left: 10px; top: 45px;'
    document.body.appendChild(rightMouseButtonIndicator)
    elem = document.createElement("img");
    elem.setAttribute("src", "icons/rightButtonPressed.png");
    document.getElementById("rightMouseButtonIndicator").appendChild(elem);
    fade('rightMouseButtonIndicator', 1, 0, 10, new Date().getTime());

    # add the div highlighting the percentage progress of the test
    testProgressIndicator = document.createElement('div')
    testProgressIndicator.id = "testProgressIndicator"
    testProgressIndicator.style.cssText = 'position: absolute; left: 10px; top: 10px; font-size: xx-large; font-family: sans-serif;'
    document.body.appendChild(testProgressIndicator)
    fade('testProgressIndicator', 1, 0, 10, new Date().getTime());

    # add the div with title and description of the test
    testTitleAndDescription = document.createElement('div')
    testTitleAndDescription.id = "testTitleAndDescription"
    testTitleAndDescription.style.cssText = 'position: absolute; left: 10px; top: 10px; font-size: 1.5em; font-family: sans-serif; background-color: rgba(128, 128, 128, 1); width: 700px; height: 500px; padding: 50px; color: white;'
    document.body.appendChild(testTitleAndDescription)
    fade('testTitleAndDescription', 1, 0, 10, new Date().getTime());
    #testTitleAndDescription.innerHTML = "Test asdasdasdasdasdakjhdasdasdasd"


    
