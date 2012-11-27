class Monarch.Relations.Offset extends Monarch.Relations.Relation
  @deriveEquality 'operand', 'count'

  constructor: (@operand, @count) ->
    @orderByExpressions = operand.orderByExpressions

  wireRepresentation: ->
    type: 'Offset'
    operand: @operand.wireRepresentation()
    count: @count

  getColumn: (args...) -> @operand.getColumn(args...)
  inferJoinColumns: (args...) -> @operand.inferJoinColumns(args...)
  columns: (args...) -> @operand.columns(args...)
