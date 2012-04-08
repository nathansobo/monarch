class Monarch.Relations.Projection extends Monarch.Relations.Relation
  @deriveEquality 'operand', 'table'

  constructor: (@operand, table) ->
    @table = if _.isFunction(table) then table.table else table
    @buildOrderByExpressions()
    @recordCounts = new JS.Hash()
    @recordCounts.setDefault(0)

  all: ->
    if @_contents
      @_contents.values()
    else
      _.uniq(@_all())

  _all: ->
    @operand.map (composite) => composite.getRecord(@table.name)

  buildOrderByExpressions: ->
    @orderByExpressions = _.filter @operand.orderByExpressions, (orderByExpression) =>
      orderByExpression.column.table.name == @table.name

  _activate: ->
    @operand.activate()
    super

    @subscribe @operand, 'onInsert', (tuple, _, newKey, oldKey) ->
      @insert(tuple.getRecord(@table.name), newKey, oldKey)

    @subscribe @operand, 'onUpdate', (tuple, changeset, _, _, newKey, oldKey) ->
      @tupleUpdated(tuple, changeset, newKey, oldKey)

    @subscribe @operand, 'onRemove', (tuple, _, newKey, oldKey) ->
      @remove(tuple.getRecord(@table.name), newKey, oldKey)

  insert: (record, newKey) ->
    rc = @recordCounts
    count = rc.put(record, rc.get(record) + 1)
    super(record, newKey) if count == 1

  tupleUpdated: (tuple, changeset, newKey, oldKey) ->
    return unless @changesetInProjection(changeset)
    return if @lastUpdate == changeset
    @lastUpdate = changeset
    super(tuple.getRecord(@table.name), changeset, newKey, oldKey)

  remove: (record, newKey, oldKey) ->
    rc = @recordCounts
    count = rc.put(record, rc.get(record) - 1)
    if count == 0
      rc.remove(record)
      super(record, newKey, oldKey)

  changesetInProjection: (changeset) ->
    _.values(changeset)[0].column.table.name == @table.name

  wireRepresentation: ->
    type: 'table_projection',
    operand: @operand.wireRepresentation(),
    projected_table: @table.remoteName

  getColumn: (args...) -> @table.getColumn(args...)
  inferJoinColumns: (args...) -> @table.inferJoinColumns(args...)
  columns: (args...) -> @table.columns(args...)
