# Klass ////////////////////////////////////////////////////////////

class Klass
  @allKlasses: []
  propertiesSources: null
  staticPropertiesSources: null
  name: ""
  superClassName: null
  augmentedWith: null
  superKlass: null
  subKlasses: null
  instances: null

  # adds code into the constructor, such that when a
  # Morph is created, it registers itself as in instance
  # on the Klass it belongs to.
  # The check:
  #     @constructor.name == arguments.callee.name\
  # is added so that the morph registers itself only
  # for the immediate klass it belongs to and not all the
  # other superclasses (in cases for example the constructor
  # calls "super", we want to avoid that any constructor
  # up the chain causes the object to register itself
  # with all the superclasses.
  # this mechanism can be tested by opening an AnalogClockMorph and
  # then from the console:
  # world.children[0].constructor.klass.instances[0] === world.children[0]
  # or
  # AnalogClockMorph.klass.instances[0] === world.children[0]
  _addInstancesTracker: (aString) ->
    # the regex to get the actual spacing under the constructor
    # is:
    # [ \t]*constructor:[ \t]*->.*$\n([ \t]*)
    # but let's keep it simple: there are going to be four spaces under for the
    # body of the constructor
    aString += "\n    return\n"
    aString.replace(/^([ \t]*)return/gm, "$1if @constructor.name == arguments.callee.name\n$1  this.constructor.klass.instances.push @\n$1  return")
    
  _equivalentforSuper: (fieldName, aString) ->
    # coffeescript won't compile "super" unless it's an instance
    # method (i.e. if it comes inside a class), so we need to
    # translate that manually into valid CS that doesn't use super.
    aString = aString.replace(/super\(\)/g, @name + ".__super__." + fieldName + ".call(this)")
    aString = aString.replace(/super\(/g, @name + ".__super__." + fieldName + ".call(this, ")
    aString = aString.replace(/super$/gm, @name + ".__super__." + fieldName + ".apply(this, arguments)")

  _removeHelperFunctions: (aString) ->
    aString = aString.replace("var slice = [].slice;\n", "")
    aString = aString.replace("var indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };\n", "")

  _addSuperClass: (theSuperClassName) ->
    @superKlass = window[theSuperClassName].klass
    window[theSuperClassName].klass.subKlasses.push @
    @superClassName = theSuperClassName

  constructor: (source) ->
    @propertiesSources = {}
    @staticPropertiesSources = {}
    @subKlasses = []
    @instances = []
    splitSource = source.split "\n"
    console.log "splitSource: " + splitSource
    sourceWithoutComments = ""
    multilineComment = false
    for eachLine in splitSource
      #console.log "eachLine: " + eachLine
      if /^[ \t]*###/m.test(eachLine)
        multilineComment = !multilineComment

      if (! /^[ \t]*#/m.test(eachLine)) and (!multilineComment)
        sourceWithoutComments += eachLine + "\n"

    # remove the bit we use to identify classe because it's going to
    # mangle the parsing and we can add it transparently
    sourceWithoutComments = sourceWithoutComments.replace("namedClasses[@name] = @prototype\n","")

    classRegex = /^class[ \t]*([a-zA-Z_$][0-9a-zA-Z_$]*)/m;
    if (m = classRegex.exec(sourceWithoutComments))?
        m.forEach((match, groupIndex) ->
            console.log("Found match, group #{groupIndex}: #{match}")
        )
        @name = m[1]
        console.log "name: " + @name

    extendsRegex = /^class[ \t]*[a-zA-Z_$][0-9a-zA-Z_$]*[ \t]*extends[ \t]*([a-zA-Z_$][0-9a-zA-Z_$]*)/m;
    if (m = extendsRegex.exec(sourceWithoutComments))?
        m.forEach((match, groupIndex) ->
            console.log("Found match, group #{groupIndex}: #{match}")
        )
        @_addSuperClass m[1]
        console.log "superClassName: " + @superClassName

    @augmentedWith = []
    augmentRegex = /^  @augmentWith[ \t]*([a-zA-Z_$][0-9a-zA-Z_$]*)/gm;
    while (m = augmentRegex.exec(sourceWithoutComments))?
        if (m.index == augmentRegex.lastIndex)
            augmentRegex.lastIndex++
        m.forEach((match, groupIndex) ->
            console.log("Found match, group #{groupIndex}: #{match}");
        )
        @augmentedWith.push m[1]
        console.log "augmentedWith: " + @augmentedWith


    # remove the augmentations because we don't want
    # them to mangle up the parsing
    sourceWithoutComments = sourceWithoutComments.replace(/^  @augmentWith[ \t]*([a-zA-Z_$][0-9a-zA-Z_$]*)/gm,"")

    console.log "sourceWithoutComments ---------\n" + sourceWithoutComments

    # to match a valid JS variable name (we just ignore the keywords):
    #    [a-zA-Z_$][0-9a-zA-Z_$]*
    regex = /^  (@?[a-zA-Z_$][0-9a-zA-Z_$]*): ([^]*?)(?=^  (@?[a-zA-Z_$][0-9a-zA-Z_$]*):)/gm
    lastField = null
    while (m = regex.exec(sourceWithoutComments))?
        if (m.index == regex.lastIndex)
            regex.lastIndex++
        m.forEach((match, groupIndex) ->
            if groupIndex == 3
              lastField = match
            console.log("Found match, group #{groupIndex}: #{match}");
        )
        if m[1].substring(0, 1) == "@"
          @staticPropertiesSources[m[1].substring(1, m[1].length)] = m[2]
        else
          @propertiesSources[m[1]] = m[2]

    console.log "last one !!!!!!!!!!!!!!!!!!!!!!!!"
    regexLast = ///#{lastField}:([^]*)///g
    while (m = regexLast.exec(sourceWithoutComments))?
        if (m.index == regexLast.lastIndex)
            regexLast.lastIndex++
        m.forEach((match, groupIndex) ->
            console.log("Found match, group #{groupIndex}: #{match}");
        )
        if lastField.substring(0, 1) == "@"
          @staticPropertiesSources[lastField.substring(1, lastField.length)] = m[1]
        else
          @propertiesSources[lastField] = m[1]

    console.dir @propertiesSources

    # the class itself is a function, the constructor:
    console.log "adding the constructor"
    if @propertiesSources["constructor"]?

      constructorDeclaration = @_equivalentforSuper "constructor", @propertiesSources["constructor"]
      constructorDeclaration = @_addInstancesTracker constructorDeclaration
      console.log "constructor declaration CS: " + constructorDeclaration

      try
        compiled = CoffeeScript.compile constructorDeclaration,{"bare":true}
      catch err
        console.log "source:"
        console.log constructorDeclaration
        console.log "error:"
        console.log err

      constructorDeclaration = "window." + @name + " = " + compiled
      constructorDeclaration = @_removeHelperFunctions constructorDeclaration

      console.log "constructor declaration JS: " + constructorDeclaration
      #if @name == "StringMorph2" then debugger
      eval.call window, constructorDeclaration
    else
      window[@name] = ->
        # first line here is equivalent to super()
        window[@name].__super__.constructor.call(this);
        # register instance
        if @constructor.name == arguments.callee.name
          this.constructor.klass.instances.push @

    # if you declare a constructor (i.e. a Function) like this then you don't
    # get the "name" property set as it normally is when
    # defining functions in ways that specify the name, so
    # we add the name manually here.
    # the name property is tricky, see:
    # see http://stackoverflow.com/questions/5871040/how-to-dynamically-set-a-function-object-name-in-javascript-as-it-is-displayed-i
    # just doing this is not sufficient: window[@name].name = @name
    Object.defineProperty(window[@name], "name", { value: @name });

    # if the class extends another one
    if @superClassName?
      console.log "extend: " + @name + " extends " + @superClassName
      window[@name] = extend window[@name], window[@superClassName]


    # if the class is augmented with one or more Mixins
    for eachAugmentation in @augmentedWith
      console.log "augmentedWith: " + eachAugmentation
      window[@name].augmentWith window[eachAugmentation]

    # non-static fields, which are put in the prototype
    for own fieldName, fieldValue of @propertiesSources
      if fieldName != "constructor" and fieldName != "augmentWith" and fieldName != "addInstanceProperties"
        console.log "building field " + fieldName + " ===== "

        fieldDeclaration = @_equivalentforSuper fieldName, fieldValue

        try
          compiled = CoffeeScript.compile fieldDeclaration,{"bare":true}
        catch err
          console.log "source:"
          console.log fieldDeclaration
          console.log "error:"
          console.log err

        fieldDeclaration = "window." + @name + ".prototype." + fieldName + " = " + compiled
        fieldDeclaration = @_removeHelperFunctions fieldDeclaration

        console.log "field declaration: " + fieldDeclaration
        #if @name == "StringMorph2" then debugger
        eval.call window, fieldDeclaration

    # now the static fields, which are put in the constructor
    # rather than in the prototype
    for own fieldName, fieldValue of @staticPropertiesSources
      if fieldName != "constructor" and fieldName != "augmentWith" and fieldName != "addInstanceProperties"
        console.log "building STATIC field " + fieldName + " ===== "

        fieldDeclaration = @_equivalentforSuper fieldName, fieldValue

        try
          compiled = CoffeeScript.compile fieldDeclaration,{"bare":true}
        catch err
          console.log "source:"
          console.log fieldDeclaration
          console.log "error:"
          console.log err

        fieldDeclaration = "window." + @name + "." + fieldName + " = " + compiled
        fieldDeclaration = @_removeHelperFunctions fieldDeclaration

        console.log fieldDeclaration
        eval.call window, fieldDeclaration

    # finally, add the class to the namedClasses index
    if @name != "MorphicNode"
      namedClasses[@name] = window[@name].prototype

    window[@name].klass = @

  notifyInstancesOfSourceChange: (propertiesArray)->
    for eachInstance in @instances
      eachInstance.sourceChanged()
  
    for eachProperty in propertiesArray
      for eachSubKlass in @subKlasses
        # if a subclass redefined a property, then
        # the change doesn't apply, so there is no
        # notification to propagate
        if !eachSubKlass.propertiesSources[eachProperty]?
          eachSubKlass.notifyInstancesOfSourceChange([eachProperty])

