#= require monarch/expressions/predicate

class Monarch.Expressions.LessThanOrEqual extends Monarch.Expressions.Predicate
  wireRepresentationType: 'lte'

  operator: (left, right) ->
    left <= right
