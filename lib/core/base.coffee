class Monarch.Base
  @deriveEquality: (properties...) ->
    @prototype.isEqual = (other) ->
      return false unless other instanceof @constructor
      for property in properties
        return false unless _.isEqual(this[property], other[property])
      true

  @delegate: (methodNames..., {to}) ->
    for methodName in methodNames
      do (methodName) =>
        @prototype[methodName] = (args...) -> this[to][methodName](args...)

  { capitalize } = Monarch.Util.Inflection

  @accessors: (methodNames...) ->
    for methodName in methodNames
      do (methodName) =>
        setterName = "set" + capitalize(methodName)
        memoizedName = "_#{methodName}"
        @prototype[methodName] = (value) ->
          this[memoizedName]
        @prototype[setterName] = (value) ->
          this[memoizedName] = value

  @reopen: (f) ->
    prototypeProperties = f.call(this)
    _.extend(this.prototype, prototypeProperties)
