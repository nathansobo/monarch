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
