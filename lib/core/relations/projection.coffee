class Monarch.Relations.Projection extends Monarch.Relations.Relation
  @deriveEquality 'operand', 'table'

  constructor: (@operand, table) ->
    @table = if _.isFunction(table) then table.table else table
    @buildOrderByExpressions()
    @recordCounts = {}

  buildOrderByExpressions: ->
    @orderByExpressions = _.filter @operand.orderByExpressions, (orderByExpression) =>
      orderByExpression.column.table.name == @table.name

  insert: (record, newKey) ->
    @recordCounts[record.id()] ?= 0
    count = (@recordCounts[record.id()] += 1)
    super(record, newKey) if count == 1

  tupleUpdated: (tuple, changeset, newKey, oldKey) ->
    return unless @changesetInProjection(changeset)
    return if @lastUpdate == changeset
    @lastUpdate = changeset
    super(tuple.getRecord(@table.name), changeset, newKey, oldKey)

  remove: (record, newKey, oldKey) ->
    count = (@recordCounts[record.id()] -= 1)
    if count == 0
      delete @recordCounts[record.id()]
      super(record, newKey, oldKey)

  changesetInProjection: (changeset) ->
    _.values(changeset)[0].column.table.name == @table.name

  wireRepresentation: ->
    type: 'Projection'
    operand: @operand.wireRepresentation()
    table: @table.name

  getColumn: (args...) -> @table.getColumn(args...)
  inferJoinColumns: (args...) -> @table.inferJoinColumns(args...)
  columns: (args...) -> @table.columns(args...)
