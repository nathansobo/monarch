class Monarch.Relations.Offset extends Monarch.Relations.Relation
  @deriveEquality 'operand', 'count'

  constructor: (@operand, @count) ->
    @orderByExpressions = operand.orderByExpressions

  _all: ->
    @operand.all()[@count..]

  _activate: ->
    @operand.activate()
    super

    @subscribe @operand, 'onInsert', (tuple, index, newKey, oldKey) ->
      if index < @count
        newFirstTuple = @operand.at(@count)
        @insert(newFirstTuple) if newFirstTuple
      else
        @insert(tuple, newKey, oldKey)

    @subscribe @operand, 'onUpdate', (tuple, changeset, newIndex, oldIndex, newKey, oldKey) ->
      if oldIndex < @count
        if newIndex >= @count
          oldFirstTuple = @at(0)
          @remove(oldFirstTuple) if oldFirstTuple
          @insert(tuple, newKey, oldKey)
      else
        if newIndex < @count
          @remove(tuple, newKey, oldKey, changeset)
          newFirstTuple = @operand.at(@count)
          @insert(newFirstTuple) if newFirstTuple
        else
          @tupleUpdated(tuple, changeset, newKey, oldKey)

    @subscribe @operand, 'onRemove', (tuple, index, newKey, oldKey) ->
      if index < @count
        oldFirstTuple = @at(0)
        @remove(oldFirstTuple) if oldFirstTuple
      else
        @remove(tuple, newKey, oldKey)

  wireRepresentation: ->
    type: 'offset',
    operand: @operand.wireRepresentation(),
    count: @count

  getColumn: (args...) -> @operand.getColumn(args...)
  inferJoinColumns: (args...) -> @operand.inferJoinColumns(args...)
  columns: (args...) -> @operand.columns(args...)
