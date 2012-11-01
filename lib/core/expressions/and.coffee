class Monarch.Expressions.And extends Monarch.Expressions.Predicate
  wireRepresentationType: 'And'

  evaluate: (tuple) ->
    @left.evaluate(tuple) && @right.evaluate(tuple)

  satisfyingAttributes: ->
    _.extend(@left.satisfyingAttributes(), @right.satisfyingAttributes())

  resolve: (relation) ->
    new @constructor(relation.resolvePredicate(@left), relation.resolvePredicate(@right))
