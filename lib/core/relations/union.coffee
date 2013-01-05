class Monarch.Relations.Union extends Monarch.Relations.Relation
  @deriveEquality 'left', 'right'
  @delegate 'getColumn', 'inferJoinColumns', 'columns', to: 'left'

  constructor: (left, right) ->
    @left = left
    @right = right
    @orderByExpressions = @left.orderByExpressions

  tupleUpdated: (tuple, changeset, newKey, oldKey) ->
    return if @lastUpdate == changeset
    @lastUpdate = changeset
    super(tuple, changeset, newKey, oldKey)

  wireRepresentation: ->
    type: 'Union'
    leftOperand: @left.wireRepresentation()
    rightOperand: @right.wireRepresentation()
