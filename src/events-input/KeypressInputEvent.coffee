# this file is only needed for Macros

class KeypressInputEvent extends KeyboardInputEvent

  charCode: nil
  which: nil

  constructor: (keyCode, @charCode, @which, shiftKey, ctrlKey, altKey, metaKey) ->
    super keyCode, shiftKey, ctrlKey, altKey, metaKey
