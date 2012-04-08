#= require monarch/expressions/predicate

class Monarch.Expressions.GreaterThan extends Monarch.Expressions.Predicate
  wireRepresentationType: 'gt'

  operator: (left, right) ->
    left > right;
