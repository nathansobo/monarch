class Monarch.Expressions.LessThanOrEqual extends Monarch.Expressions.Predicate
  wireRepresentationType: 'LessThanOrEqual'

  operator: (left, right) ->
    left <= right
