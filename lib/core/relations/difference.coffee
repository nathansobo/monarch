class Monarch.Relations.Difference extends Monarch.Relations.Relation
  @deriveEquality 'left', 'right'

  constructor: (@left, @right) ->
    @orderByExpressions = left.orderByExpressions

  wireRepresentation: ->
    type: 'Difference',
    leftOperand: @left.wireRepresentation(),
    rightOperand: @right.wireRepresentation()

  getColumn: (args...) -> @left.getColumn(args...)
  inferJoinColumns: (args...) -> @left.inferJoinColumns(args...)
  columns: (args...) -> @left.columns(args...)
