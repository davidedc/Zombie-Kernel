# I mark where the caret is in a String/Text while editing

class CaretMorph extends BlinkerMorph

  keyDownEventUsed: false
  target: nil
  slot: nil
  viewPadding: 1
  currentCaretFontSize: nil

  constructor: (@target) ->
    # additional properties:
    @slot = @target.text.length
    super()

    # if the only thing in the undo history is the
    # first positioning of the caret via click, we can clear
    # that because we are going to set out own with
    # the first click
    if @target.undoHistory?.length == 1
      onlyUndo = @target.undoHistory[@target.undoHistory.length - 1]
      if onlyUndo.isJustFirstClickToPositionCursor
        @target.undoHistory = []

    # font could be really small I guess?
    @minimumExtent = new Point 1,1

    if (@target instanceof TextMorph) and (@target.alignment != 'left')
      @target.setAlignmentToLeft()
    @adjustAccordingToTargetText()

  adjustAccordingToTargetText: ->
    @updateDimension()
    @gotoSlot @slot

  justBeforeBeingPainted: ->
    @adjustAccordingToTargetText()

  updateDimension: ->
    ls = @target.fontHeight @target.actualFontSizeUsedInRendering()
    if ls != @currentCaretFontSize
      @currentCaretFontSize = ls
      @rawSetExtent new Point Math.max(Math.floor(ls / 20), 1), ls
  
  # CaretMorph event processing:
  processKeyPress: (key, code, shiftKey, ctrlKey, altKey, metaKey) ->
    # @inspectKeyEvent event
    if @keyDownEventUsed
      @keyDownEventUsed = false
      @updateDimension()
      return nil
    if ctrlKey
      @ctrl key, shiftKey
    # in Chrome/OSX cmd-a and cmd-z
    # don't trigger a keypress so this
    # function invocation here does
    # nothing.
    else if metaKey
      @cmd key, shiftKey
    else
      @insert key, shiftKey
    # notify target's parent of key event
    @target.escalateEvent "reactToKeystroke", key, code, shiftKey, ctrlKey, altKey, metaKey
    @updateDimension()
  
  # Some "keys" don't produce a keypress,
  # they just produce a keydown/keyup,
  # (see https://stackoverflow.com/q/1367700 )
  # so we handle those here.
  # Note that we use the keyDownEventUsed flag
  # to absolutely make sure that we don't process
  # the same thing twice just in case in some
  # platforms some unexpected keys DO produce
  # both the keydown + keypress ...
  processKeyDown: (key, code, shiftKey, ctrlKey, altKey, metaKey) ->
    # @inspectKeyEvent event
    @keyDownEventUsed = false
    if ctrlKey
      @ctrl key, shiftKey
      # notify target's parent of key event
      @target.escalateEvent "reactToKeystroke", key, code, shiftKey, ctrlKey, altKey, metaKey
      @updateDimension()
      return
    else if metaKey
      if key == "z" then debugger
      @cmd key, shiftKey
      # notify target's parent of key event
      @target.escalateEvent "reactToKeystroke", key, code, shiftKey, ctrlKey, altKey, metaKey
      @updateDimension()
      return

    # see:
    #   https://developer.mozilla.org/en-US/docs/Web/API/KeyboardEvent/key/Key_Values
    #   https://w3c.github.io/uievents/tools/key-event-viewer.html
    switch key
      when " "
        # when you do a preventDefault() on the spacebar,
        # (to avoid the page to scroll), then the
        # keypress event for the space doesn't happen
        # (at least in Chrome/OSX),
        # so we must process it in the keydown here instead!
        @insert " "
        @keyDownEventUsed = true
      when "ArrowLeft"
        @goLeft shiftKey
        @keyDownEventUsed = true
      when "ArrowRight"
        @goRight shiftKey
        @keyDownEventUsed = true
      when "ArrowUp"
        @goUp shiftKey
        @keyDownEventUsed = true
      when "ArrowDown"
        @goDown shiftKey
        @keyDownEventUsed = true
      when "Home"
        @goHome shiftKey
        @keyDownEventUsed = true
      when "End"
        @goEnd shiftKey
        @keyDownEventUsed = true
      when "Delete"
        @deleteRight()
        @keyDownEventUsed = true
      when "Backspace"
        @deleteLeft()
        @keyDownEventUsed = true
      when "Tab"
        # TAB is another key that doesn't
        # produce a keypress in all browsers/OSs
        @keyDownEventUsed = true
        if @target?
          if shiftKey
            return @target.backTab @target
          else
            if @target instanceof SimplePlainTextWdgt
              @insert "  "
              @keyDownEventUsed = true
            else
              return @target.tab @target

      when "Enter"
        # we can't check the class using instanceof
        # because TextMorphs are instances of StringMorphs
        # but they want the enter to insert a carriage return.
        if @target.constructor.name == "StringMorph" or @target.constructor.name == "StringMorph2"
          @accept()
        else
          @insert "\n"
        @keyDownEventUsed = true
      when "Escape"
        @cancel()
        @keyDownEventUsed = true
      else
    # @inspectKeyEvent event
    # notify target's parent of key event
    @target.escalateEvent "reactToKeystroke", key, code, shiftKey, ctrlKey, altKey, metaKey
    @updateDimension()
  
  processCut: (selectedText) ->
    #console.log "processing cut"
    # see comment on outstandingTimerTriggeredOperationsCounter
    # above where the property is declared and initialised.
    world.outstandingTimerTriggeredOperationsCounter.push true
    window.setTimeout ( =>
     @deleteLeft()
     world.outstandingTimerTriggeredOperationsCounter.pop()
    ), 50, true


  # unused
  processCopy: (selectedText) ->
    #console.log "processing copy"

  processPaste: (clipboardText) ->
    # Needs a few msec to execute paste
    #console.log "about to insert text: " + clipboardText

    # see comment on outstandingTimerTriggeredOperationsCounter
    # above where the property is declared and initialised.
    world.outstandingTimerTriggeredOperationsCounter.push true
    window.setTimeout ( =>
     @insert clipboardText
     world.outstandingTimerTriggeredOperationsCounter.pop()
    ), 50, true

  
  gotoSlot: (slot, becauseOfMouseClick) ->
    # check that slot is within the allowed boundaries of
    # of zero and text length.
    length = @target.text.length
    @slot = (if slot < 0 then 0 else (if slot > length then length else slot))

    pos = @target.slotCoordinates @slot
    if pos?
      if @parent and @target.isScrollable
        right = @parent.right() - @viewPadding
        left = @parent.left() + @viewPadding
        if pos.x > right
          @target.fullRawMoveLeftSideTo @target.left() + right - pos.x
          pos.x = right
        if pos.x < left
          left = Math.min @parent.left(), left
          @target.fullRawMoveLeftSideTo @target.left() + left - pos.x
          pos.x = left
        if @target.right() < right and right - @target.width() < left
          pos.x += right - @target.right()
          @target.fullRawMoveRightSideTo right
      #console.log "moving caret to: " + pos
      @show()
      @fullRawMoveTo pos.floor()

      if @amIDirectlyInsideScrollPanelWdgt() and @target.isScrollable
        @parent.parent.scrollCaretIntoView @

    if becauseOfMouseClick and @target.undoHistory?.length == 0
      @target.pushUndoState? @slot, true

  
  goLeft: (shift) ->
    if !shift and @target.firstSelectedSlot()?
      @gotoSlot @target.firstSelectedSlot()
      @updateSelection shift
    else
      @updateSelection shift
      @gotoSlot @slot - 1
      @updateSelection shift
      @clearSelectionIfStartAndEndMeet shift
    @target.caretHorizPositionForVertMovement = @slot
  
  goRight: (shift, howMany) ->
    if !shift and @target.lastSelectedSlot()?
      @gotoSlot @target.lastSelectedSlot()
      @updateSelection shift
    else
      @updateSelection shift
      @gotoSlot @slot + (howMany || 1)
      @updateSelection shift
      @clearSelectionIfStartAndEndMeet shift
    @target.caretHorizPositionForVertMovement = @slot
  
  goUp: (shift) ->
    if !shift and @target.lastSelectedSlot()?
      @gotoSlot @target.firstSelectedSlot()
      @updateSelection shift
    else
      @updateSelection shift
      @gotoSlot @target.upFrom @slot
      @updateSelection shift
      @clearSelectionIfStartAndEndMeet shift
  
  goDown: (shift) ->
    if !shift and @target.lastSelectedSlot()?
      @gotoSlot @target.lastSelectedSlot()
      @updateSelection shift
    else
      @updateSelection shift
      @gotoSlot @target.downFrom @slot
      @updateSelection shift
      @clearSelectionIfStartAndEndMeet shift
  
  goHome: (shift) ->
    @updateSelection shift
    @gotoSlot @target.startOfLine @slot
    @updateSelection shift
    @clearSelectionIfStartAndEndMeet shift
  
  goEnd: (shift) ->
    @updateSelection shift
    @gotoSlot @target.endOfLine @slot
    @updateSelection shift
    @clearSelectionIfStartAndEndMeet shift
  
  gotoPos: (aPoint) ->
    slotToGoTo = @target.slotAt aPoint
    @gotoSlot slotToGoTo
    @show()
    return slotToGoTo

  clearSelectionIfStartAndEndMeet: (shift) ->
    if shift
      #console.log "@target.startMark: " + @target.startMark + " @target.endMark: " + @target.endMark
      if @target.startMark == @target.endMark
        #console.log "clearSelectionIfStartAndEndMeet clearing selection"
        @target.clearSelection()

  updateSelection: (shift) ->
    if shift
      if (!@target.endMark?) and (!@target.startMark?)
        @target.selectBetween @slot, @slot
      else if @target.endMark isnt @slot
        @target.setEndMark @slot
    else
      @target.clearSelection()
  
  # CaretMorph editing.

  # User presses enter on a stringMorph
  accept: ->
    world.stopEditing()
    @escalateEvent "accept", nil
  
  # User presses ESC
  cancel: ->
    world.stopEditing()
    @escalateEvent 'cancel', nil

  # User presses CTRL-Z or CMD-Z, potentially with shift
  undo: (shiftKey) ->
    if !@target.undoHistory?
      return

    if !shiftKey
      if @target.undoHistory.length > 1
        @target.popUndoState()
        undoState = @target.undoHistory[@target.undoHistory.length - 1]
        @bringTextAndCaretToState undoState
    else
      redoState = @target.popRedoState()
      if redoState?
        @bringTextAndCaretToState redoState

  bringTextAndCaretToState: (state) ->
    @target.setText state.textContent, nil, nil
    @gotoSlot state.cursorPos
    if state.selectionStart? and state.selectionEnd?
      @target.selectBetween state.selectionStart, state.selectionEnd
    else
      @target.clearSelection()
  
  insert: (key, shiftKey) ->
    # if the target "isNumeric", then only accept
    # numbers and "-" and "." as input
    if not @target.isNumeric or not isNaN(parseFloat(key)) or key in ["-", "."]
      
      # we push the state here before the change, then again
      # after the change. This seems redundant, however
      # it's needed because:
      #
      # 1) in case we are about to insert something that
      #    replaces a selection, then it's actually
      #    important to save the state before the selection
      #    is touched so that the user can go back to it
      # 2) in case of edit "far" from the previous edit,
      #    this is going to be very very useful because
      #    it's much *much* more natural
      #    for the user to undo up to the position BEFORE an
      #    edit. If you don't save that position before the
      #    edit, you jump directly to the end of the edit before,
      #    it's actually quite puzzling.
      #    It's nominally "functional" to only jump to text changes,
      #    but it's quite unnatural, it's not how undos work
      #    in real editors.
      # 
      # In the "normal" case of continuous typing this
      # would be indeed redundant, HOWEVER we avoid such
      # redundancy, because the sequences of:
      #
      #         position, text, position, text, ...
      #
      # actually are saved without the "position"
      # changes (there is a check in "pushUndoState" that if there
      # is only a change position of one then that state is not
      # pushed)

      @target.pushUndoState? @slot

      if @target.selection() isnt ""
        @gotoSlot @target.firstSelectedSlot()
        @target.deleteSelection()
      text = @target.text
      text = text.slice(0, @slot) + key + text.slice(@slot)
      # this is a setText that will trigger the text
      # connections "from within", starting a new connections
      # update round
      @target.setText text, nil, nil
      @goRight false, key.length
      @updateDimension()
      @target.pushUndoState? @slot
  
  ctrl: (key, shiftKey) ->
    # ctrl-a apparently can come from either
    # keypress or keydown
    # 64 is for keydown
    # 97 is for keypress
    # in Chrome on OSX there is no keypress
    switch key
      when "a", "A"
        @target.selectAll()
      # ctrl-z arrives both via keypress and
      # keydown but 90 here matches the keydown only
      when "z", "Z"
        @undo shiftKey

  # these two arrive only from
  # keypressed, at least in Chrome/OSX
  # 65 and 90 are both scan codes.
  cmd: (key, shiftKey) ->
    # CMD-A
    switch key
      when "a", "A"
        @target.selectAll()
      # CMD-Z
      when "z", "Z"
        @undo shiftKey
  
  deleteRight: ->
    if @target.selection() isnt ""
      @gotoSlot @target.firstSelectedSlot()
      @target.deleteSelection()
    else
      text = @target.text
      text = text.slice(0, @slot) + text.slice(@slot + 1)
      @target.setText text, nil, nil
  
  deleteLeft: ->
    if @target.selection()
      @gotoSlot @target.firstSelectedSlot()
      @target.deleteSelection()
    else
      text = @target.text
      @target.setText text.substring(0, @slot - 1) + text.substr(@slot), nil, nil
      @goLeft()

    @updateSelection false
    @gotoSlot @slot
    @updateSelection false
    @clearSelectionIfStartAndEndMeet false
  
  # »>> this part is excluded from the fizzygum homepage build
  # CaretMorph utilities:
  inspectKeyEvent: (event) ->
    # private
    @inform "Key pressed: " + event.key + "\n------------------------" + "\nkey: " + event.key + "\ncode: " + event.code + "\naltKey: " + event.altKey + "\nctrlKey: " + event.ctrlKey  + "\ncmdKey: " + event.metaKey
  # this part is excluded from the fizzygum homepage build <<«
