class Monarch.Relations.Selection extends Monarch.Relations.Relation
  @deriveEquality 'operand', 'predicate'

  constructor: (@operand, predicate) ->
    @predicate = @resolvePredicate(predicate)
    @orderByExpressions = operand.orderByExpressions

  create: (attributes) ->
    @operand.create(_.extend({}, attributes, @predicate.satisfyingAttributes()))

  created: (attributes) ->
    @operand.created(_.extend({}, attributes, @predicate.satisfyingAttributes()))

  _all: ->
    _.filter @operand.all(), (tuple) => @predicate.evaluate(tuple)

  _activate: ->
    @operand.activate()
    super

    @subscribe @operand, 'onInsert', (tuple, _, newKey, oldKey) ->
      @insert(tuple, newKey, oldKey) if @predicate.evaluate(tuple)

    @subscribe @operand, 'onUpdate', (tuple, changeset, _, _, newKey, oldKey) ->
      if @predicate.evaluate(tuple)
        if @containsKey(oldKey)
          @tupleUpdated(tuple, changeset, newKey, oldKey)
        else
          @insert(tuple, newKey, oldKey)
      else
        @remove(tuple, newKey, oldKey, changeset) if (@containsKey(oldKey))

    @subscribe @operand, 'onRemove', (tuple, _, newKey, oldKey) ->
      @remove(tuple, newKey, oldKey) if (@containsKey(oldKey))

  wireRepresentation: ->
    type: 'selection',
    predicate: @predicate.wireRepresentation(),
    operand: @operand.wireRepresentation()

  getColumn: (args...) -> @operand.getColumn(args...)
  inferJoinColumns: (args...) -> @operand.inferJoinColumns(args...)
  columns: (args...) -> @operand.columns(args...)
