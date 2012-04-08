#= require monarch/expressions/predicate

class Monarch.Expressions.GreaterThanOrEqual extends Monarch.Expressions.Predicate
  wireRepresentationType: 'gte'

  operator: (left, right) ->
    left >= right
