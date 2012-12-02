class Monarch.Relations.OrderBy extends Monarch.Relations.Relation
  @deriveEquality 'operand', 'orderByExpressions'
  @delegate 'getColumn', 'inferJoinColumns', 'columns',
    'wireRepresentation', 'create', 'created', to: 'operand'

  constructor: (@operand, orderByStrings) ->
    @orderByExpressions = @buildOrderByExpressions(orderByStrings)

  buildKey: (tuple, changeset) ->
    key = super(tuple)
    if changeset
      for name, change of changeset
        qName = change.column.qualifiedName
        key[qName] = change.oldValue if key[qName]?
    key
