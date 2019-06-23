# Extending Array's prototype if 'filter' doesn't exist
# already
unless Array::filter
  Array::filter = (callback) ->
    element for element in this when callback element

Array::deepCopy = (doSerialize, objOriginalsClonedAlready, objectClones, allMorphsInStructure) ->
  haveIBeenCopiedAlready = objOriginalsClonedAlready.indexOf @
  if haveIBeenCopiedAlready >= 0
    if doSerialize
      return "$" + haveIBeenCopiedAlready
    else
      return objectClones[haveIBeenCopiedAlready]

  positionInObjClonesArray = objOriginalsClonedAlready.length
  objOriginalsClonedAlready.push @
  cloneOfMe = []
  objectClones.push  cloneOfMe

  for i in [0... @.length]
    if !@[i]?
        cloneOfMe[i] = nil
    else if typeof @[i] == 'object'
      if !@[i].deepCopy?
        # this should never happen
        debugger
      cloneOfMe[i] = @[i].deepCopy doSerialize, objOriginalsClonedAlready, objectClones, allMorphsInStructure
    else
      cloneOfMe[i] = @[i]

  if doSerialize
    return "$" + positionInObjClonesArray

  return cloneOfMe

Array::chunk = (chunkSize) ->
  array = this
  [].concat.apply [], array.map (elem, i) ->
    if i % chunkSize then [] else [ array.slice(i, i + chunkSize) ]

# removes the elements IN PLACE, i.e. the
# array IS modified
Array::remove = (theElement) ->
  index = @indexOf theElement
  if index isnt -1
    @splice index, 1
  return @

# deduplicates array entries
# does NOT modify array in place
Array::unique = ->
  output = {}
  output[@[key]] = @[key] for key in [0...@length]
  value for key, value of output

# deduplicates array entries
# keeping the current order
# see https://stackoverflow.com/a/14438954
# does NOT modify array in place
uniqueKeepOrder = (value, index, self) ->
  self.indexOf(value) == index

Array::uniqueKeepOrder = ->
  return @filter uniqueKeepOrder


if typeof String::contains == 'undefined'
  String::contains = (it) ->
    @indexOf(it) != -1

if typeof String::isLetter == 'undefined'
  String::isLetter = ->
    @length == 1 && @match /[a-z]/i