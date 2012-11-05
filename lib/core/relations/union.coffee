class Monarch.Relations.Union extends Monarch.Relations.Relation
  @deriveEquality 'left', 'right'

  constructor: (left, right) ->
    @left = left
    @right = right
    @orderByExpressions = @left.orderByExpressions

  _activate: ->
    @left.activate()
    @right.activate()
    super

    @subscribe @left, 'onInsert', (tuple, index, newKey, oldKey) ->
      @handleOperandInsert(tuple, newKey, oldKey)

    @subscribe @right, 'onInsert', (tuple, index, newKey, oldKey) ->
      @handleOperandInsert(tuple, newKey, oldKey)

    @subscribe @left, 'onUpdate', (tuple, changeset, newIndex, oldIndex, newKey, oldKey) ->
      @tupleUpdated(tuple, changeset, newKey, oldKey)

    @subscribe @right, 'onUpdate', (tuple, changeset, newIndex, oldIndex, newKey, oldKey) ->
      @tupleUpdated(tuple, changeset, newKey, oldKey)

    @subscribe @left, 'onRemove', (tuple, index, newKey, oldKey) ->
      @handleOperandRemove('left', tuple, newKey, oldKey)

    @subscribe @right, 'onRemove', (tuple, index, newKey, oldKey) ->
      @handleOperandRemove('right', tuple, newKey, oldKey)

  handleOperandInsert: (tuple, newKey, oldKey) ->
    @insert(tuple, newKey, oldKey) unless @containsKey(newKey, oldKey)

  tupleUpdated: (tuple, changeset, newKey, oldKey) ->
    return if @lastUpdate == changeset
    @lastUpdate = changeset
    super(tuple, changeset, newKey, oldKey)

  handleOperandRemove: (side, tuple, newKey, oldKey) ->
    otherOperand = @otherOperand(side)
    @remove(tuple, newKey, oldKey) unless otherOperand.containsKey(newKey, oldKey)

  otherOperand: (side) ->
    if side == 'left' then @right else @left

  wireRepresentation: ->
    type: 'Union'
    leftOperand: @left.wireRepresentation()
    rightOperand: @right.wireRepresentation()

  getColumn: (args...) -> @left.getColumn(args...)
  inferJoinColumns: (args...) -> @left.inferJoinColumns(args...)
  columns: (args...) -> @left.columns(args...)
