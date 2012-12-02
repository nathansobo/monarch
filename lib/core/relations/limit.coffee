class Monarch.Relations.Limit extends Monarch.Relations.Relation
  @deriveEquality('operand', 'count')

  constructor: (@operand, @count) ->
    @orderByExpressions = operand.orderByExpressions

  wireRepresentation: ->
    type: 'Limit'
    operand: @operand.wireRepresentation()
    count: @count

  getColumn: (args...) -> @operand.getColumn(args...)
  inferJoinColumns: (args...) -> @operand.inferJoinColumns(args...)
  columns: (args...) -> @operand.columns(args...)
