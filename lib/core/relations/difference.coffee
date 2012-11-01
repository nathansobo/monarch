class Monarch.Relations.Difference extends Monarch.Relations.Relation
  @deriveEquality 'left', 'right'

  constructor: (@left, @right) ->
    @orderByExpressions = left.orderByExpressions

  _all: ->
    _.difference(@left.all(), @right.all())

  _activate: ->
    @right.activate()
    @left.activate()

    super

    @subscribe @left, 'onInsert', (tuple, index, newKey, oldKey) ->
      @insert(tuple, newKey, oldKey) unless @right.containsKey(newKey, oldKey)

    @subscribe @right, 'onRemove', (tuple, index, newKey, oldKey) ->
      @insert(tuple, newKey, oldKey) if @left.containsKey(newKey, oldKey)

    @subscribe @left, 'onUpdate', (tuple, changeset, newIndex, oldIndex, newKey, oldKey) ->
      @tupleUpdated(tuple, changeset, newKey, oldKey) unless @right.containsKey(newKey, oldKey)

    @subscribe @left, 'onRemove', (tuple, index, newKey, oldKey) ->
      @remove(tuple) if @containsKey(oldKey)

    @subscribe @right, 'onInsert', (tuple, index, newKey, oldKey) ->
      @remove(tuple) if @containsKey(newKey, oldKey)

  wireRepresentation: ->
    type: 'Difference',
    leftOperand: @left.wireRepresentation(),
    rightOperand: @right.wireRepresentation()

  getColumn: (args...) -> @left.getColumn(args...)
  inferJoinColumns: (args...) -> @left.inferJoinColumns(args...)
  columns: (args...) -> @left.columns(args...)
