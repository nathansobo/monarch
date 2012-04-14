#= require monarch/expressions/predicate

class Monarch.Expressions.GreaterThan extends Monarch.Expressions.Predicate
  wireRepresentationType: 'GreaterThan'

  operator: (left, right) ->
    left > right;
