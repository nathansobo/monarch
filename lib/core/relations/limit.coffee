class Monarch.Relations.Limit extends Monarch.Relations.Relation
  @deriveEquality('operand', 'count')

  constructor: (@operand, @count) ->
    @orderByExpressions = operand.orderByExpressions

  _activate: ->
    @operand.activate()
    super

    @subscribe @operand, 'onInsert', (tuple, index, newKey, oldKey) ->
      if index < @count
        oldLastTuple = @at(@count - 1)
        @remove(oldLastTuple) if oldLastTuple
        @insert(tuple, newKey, oldKey)

    @subscribe @operand, 'onUpdate', (tuple, changeset, newIndex, oldIndex, newKey, oldKey) ->
      if oldIndex < @count
        if newIndex < @count
          @tupleUpdated(tuple, changeset, newKey, oldKey)
        else
          @remove(tuple, newKey, oldKey, changeset)
          newLastTuple = @operand.at(@count - 1)
          @insert(newLastTuple) if newLastTuple
      else
        if newIndex < @count
          oldLastTuple = @at(@count - 1)
          @remove(oldLastTuple) if oldLastTuple
          @insert(tuple, newKey, oldKey)

    @subscribe @operand, 'onRemove', (tuple, index, newKey, oldKey) ->
      @remove(tuple, newKey, oldKey)
      newLastTuple = @operand.at(@count - 1)
      @insert(newLastTuple) if newLastTuple

  wireRepresentation: ->
    type: 'Limit'
    operand: @operand.wireRepresentation()
    count: @count

  getColumn: (args...) -> @operand.getColumn(args...)
  inferJoinColumns: (args...) -> @operand.inferJoinColumns(args...)
  columns: (args...) -> @operand.columns(args...)
