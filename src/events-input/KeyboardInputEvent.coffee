class KeyboardInputEvent extends InputEvent
  keyCode: nil
  shiftKey: nil
  ctrlKey: nil
  altKey: nil
  metaKey: nil

  constructor: (@keyCode, @shiftKey, @ctrlKey, @altKey, @metaKey, isSynthetic, time) ->
    super isSynthetic, time
