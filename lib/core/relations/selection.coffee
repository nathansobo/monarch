class Monarch.Relations.Selection extends Monarch.Relations.Relation
  @deriveEquality 'operand', 'predicate'
  @delegate 'getColumn', 'inferJoinColumns', 'columns', to: 'operand'

  constructor: (@operand, predicate) ->
    @predicate = @resolvePredicate(predicate)
    @orderByExpressions = operand.orderByExpressions

  create: (attributes) ->
    @operand.create(_.extend({}, attributes, @predicate.satisfyingAttributes()))

  created: (attributes) ->
    @operand.created(_.extend({}, attributes, @predicate.satisfyingAttributes()))

  wireRepresentation: ->
    type: 'Selection'
    predicate: @predicate.wireRepresentation()
    operand: @operand.wireRepresentation()
