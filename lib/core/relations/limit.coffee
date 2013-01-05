class Monarch.Relations.Limit extends Monarch.Relations.Relation
  @deriveEquality 'operand', 'count'
  @delegate 'getColumn', 'inferJoinColumns', 'columns', to: 'operand'

  constructor: (@operand, @count) ->
    @orderByExpressions = operand.orderByExpressions

  wireRepresentation: ->
    type: 'Limit'
    operand: @operand.wireRepresentation()
    count: @count

