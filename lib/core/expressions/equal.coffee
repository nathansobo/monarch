class Monarch.Expressions.Equal extends Monarch.Expressions.Predicate
  wireRepresentationType: 'Equal'

  operator: (left, right) ->
    _.isEqual(left, right)

  satisfyingAttributes: ->
    attributes = {}
    attributes[@left.name] = @right
    attributes

  isEqual: (other) ->
    return false unless other instanceof @constructor
    return true if _.isEqual(@left, other.left) and _.isEqual(@right, other.right)
    return true if _.isEqual(@left, other.right) and _.isEqual(@right, other.left)
    false
