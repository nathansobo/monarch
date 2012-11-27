class Monarch.Relations.InnerJoin extends Monarch.Relations.Relation
  @deriveEquality 'left', 'right', 'predicate'

  constructor: (left, right, predicate) ->
    @left = if _.isFunction(left) then left.table else left
    @right = if _.isFunction(right) then right.table else right
    @predicate = @resolvePredicate(predicate or @inferPredicate())
    @orderByExpressions = @left.orderByExpressions.concat(@right.orderByExpressions)

  inferPredicate: ->
    columns = @left.inferJoinColumns(@right.columns()) or @right.inferJoinColumns(@left.columns())
    throw new Error("No join predicate could be inferred") unless columns
    columns[0].eq(columns[1])

  inferJoinColumns: (columns) ->
    @left.inferJoinColumns(columns) or @right.inferJoinColumns(columns)

  columns: ->
    @left.columns().concat(@right.columns())

  getColumn: (name) ->
    @left.getColumn(name) or @right.getColumn(name)

  buildComposite: (tuple1, tuple2, sideOfTuple1) ->
    if sideOfTuple1 == 'right'
      new Monarch.CompositeTuple(tuple2, tuple1)
    else
      new Monarch.CompositeTuple(tuple1, tuple2)

  buildKey: (tuple, oldKey) ->
    key = super(tuple)
    if oldKey then _.extend(key, oldKey) else key

  wireRepresentation: ->
    type: 'InnerJoin',
    leftOperand: @left.wireRepresentation()
    rightOperand: @right.wireRepresentation()
    predicate: @predicate.wireRepresentation()
