class Monarch.Expressions.LessThan extends Monarch.Expressions.Predicate
  wireRepresentationType: 'LessThan'

  operator: (left, right) ->
    left < right
