class Monarch.Relations.Difference extends Monarch.Relations.Relation
  @deriveEquality 'left', 'right'
  @delegate 'getColumn', 'inferJoinColumns', 'columns', to: 'left'

  constructor: (@left, @right) ->
    @orderByExpressions = left.orderByExpressions

  wireRepresentation: ->
    type: 'Difference',
    leftOperand: @left.wireRepresentation(),
    rightOperand: @right.wireRepresentation()
