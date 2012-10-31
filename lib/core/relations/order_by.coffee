class Monarch.Relations.OrderBy extends Monarch.Relations.Relation
  @deriveEquality 'operand', 'orderByExpressions'
  @delegate 'getColumn', 'inferJoinColumns', 'columns',
    'wireRepresentation', 'create', 'created', to: 'operand'

  constructor: (@operand, orderByStrings) ->
    @orderByExpressions = @buildOrderByExpressions(orderByStrings)

  _all: ->
    @operand.all().sort(@buildComparator(true))

  _activate: ->
    @operand.activate()
    super

    @subscribe @operand, 'onInsert', (tuple) ->
      @insert(tuple)

    @subscribe @operand, 'onUpdate', (tuple, changeset) ->
      @tupleUpdated(tuple, changeset, @buildKey(tuple), @buildKey(tuple, changeset))

    @subscribe @operand, 'onRemove', (tuple, index, newKey, oldKey, changeset) ->
      @remove(tuple, @buildKey(tuple), @buildKey(tuple, changeset))

  buildKey: (tuple, changeset) ->
    key = super(tuple)
    if changeset
      for name, change of changeset
        qName = change.column.qualifiedName
        key[qName] = change.oldValue if key[qName]?
    key
