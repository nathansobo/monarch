#= require ./predicate

class Monarch.Expressions.NotEqual extends Monarch.Expressions.Predicate
  wireRepresentationType: 'NotEqual'

  operator: (left, right) ->
    not _.isEqual(left, right)

  isEqual: (other) ->
    return false unless other instanceof @constructor
    return true if _.isEqual(@left, other.left) and _.isEqual(@right, other.right)
    return true if _.isEqual(@left, other.right) and _.isEqual(@right, other.left)
    false
