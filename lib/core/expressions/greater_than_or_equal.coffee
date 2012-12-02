class Monarch.Expressions.GreaterThanOrEqual extends Monarch.Expressions.Predicate
  wireRepresentationType: 'GreaterThanOrEqual'

  operator: (left, right) ->
    left >= right
