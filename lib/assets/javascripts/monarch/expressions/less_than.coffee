#= require monarch/expressions/predicate

class Monarch.Expressions.LessThan extends Monarch.Expressions.Predicate
  wireRepresentationType: 'lt'

  operator: (left, right) ->
    left < right
