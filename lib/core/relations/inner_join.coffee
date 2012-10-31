#= require ./relation

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

  _all: ->
    all = []
    @left.each (leftTuple) =>
      @right.each (rightTuple) =>
        composite = @buildComposite(leftTuple, rightTuple)
        all.push(composite) if @predicate.evaluate(composite)
    all

  _activate: ->
    @left.activate()
    @right.activate()
    super

    @subscribe @left, 'onInsert', (leftTuple, index, newKey, oldKey) ->
      @handleOperandInsert('left', leftTuple, oldKey)

    @subscribe @right, 'onInsert', (rightTuple, index, newKey, oldKey) ->
      @handleOperandInsert('right', rightTuple, oldKey)

    @subscribe @left, 'onUpdate', (leftTuple, changeset, newIndex, oldIndex, newKey, oldKey) ->
      @handleOperandUpdate('left', leftTuple, changeset, oldKey)

    @subscribe @right, 'onUpdate', (rightTuple, changeset, newIndex, oldIndex, newKey, oldKey) ->
      @handleOperandUpdate('right', rightTuple, changeset, oldKey)

    @subscribe @left, 'onRemove', (leftTuple, index, newKey, oldKey) ->
      @handleOperandRemove('left', leftTuple, oldKey)

    @subscribe @right, 'onRemove', (rightTuple, index, newKey, oldKey) ->
      @handleOperandRemove('right', rightTuple, oldKey)

  otherOperand: (side) ->
    if side == 'left' then @right else @left

  handleOperandInsert: (side, tuple1, oldKey) ->
    @otherOperand(side).each (tuple2) =>
      composite = @buildComposite(tuple1, tuple2, side)
      newCompositeKey = @buildKey(composite)
      oldCompositeKey = @buildKey(composite, oldKey)
      if @predicate.evaluate(composite)
        @insert(composite, newCompositeKey, oldCompositeKey)

  handleOperandUpdate: (side, tuple1, changeset, oldKey) ->
    @otherOperand(side).each (tuple2) =>
      composite = @buildComposite(tuple1, tuple2, side)
      newCompositeKey = @buildKey(composite)
      oldCompositeKey = @buildKey(composite, oldKey)
      existingComposite = @findByKey(oldCompositeKey)

      if @predicate.evaluate(composite)
        if existingComposite
          @tupleUpdated(existingComposite, changeset, newCompositeKey, oldCompositeKey)
        else
          @insert(composite, newCompositeKey, oldCompositeKey)
      else
        if existingComposite
          @remove(existingComposite, newCompositeKey, oldCompositeKey, changeset)

  handleOperandRemove: (side, tuple1, oldKey) ->
    @otherOperand(side).each (tuple2) =>
      newComposite = @buildComposite(tuple1, tuple2, side)
      newCompositeKey = @buildKey(newComposite)
      oldCompositeKey = @buildKey(newComposite, oldKey)
      existingComposite = @findByKey(oldCompositeKey)
      if existingComposite
        @remove(existingComposite, newCompositeKey, oldCompositeKey)

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
