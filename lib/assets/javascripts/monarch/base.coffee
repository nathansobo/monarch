class Monarch.Base
  @deriveEquality: (properties...) ->
    @prototype.isEqual = (other) ->
      return false unless other instanceof @constructor
      for property in properties
        return false unless _.isEqual(this[property], other[property])
      true
