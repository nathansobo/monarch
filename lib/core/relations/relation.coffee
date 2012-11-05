class Monarch.Relations.Relation extends Monarch.Base
  size: ->
    @all().length

  isEmpty: ->
    @all().length == 0

  contains: (tuple) ->
    @indexOf(tuple) != -1

  find: (idOrPredicate) ->
    predicate = if _.isObject(idOrPredicate)
      idOrPredicate
    else
      { id: idOrPredicate }
    @where(predicate).first()

  first: ->
    @all()[0]

  last: ->
    _.last(@all())

  onInsert: (callback, context) ->
    @activate()
    @_insertNode.subscribe(callback, context)

  onUpdate: (callback, context) ->
    @activate()
    @_updateNode.subscribe(callback, context)

  onRemove: (callback, context) ->
    @activate()
    @_removeNode.subscribe(callback, context)

  forEach: (iterator, context) ->
    _.each(@all(), iterator, context)

  each: (args...) -> @forEach(args...)

  map: (iterator, context) ->
    _.map(@all(), iterator, context)

  where: (predicate) ->
    return this if _.isEmpty(predicate)
    new Monarch.Relations.Selection(this, predicate)

  join: (right, predicate) ->
    new Monarch.Relations.InnerJoin(this, right, predicate)

  project: (table) ->
    new Monarch.Relations.Projection(this, table)

  joinThrough: (table, predicate) ->
    @join(table, predicate).project(table)

  union: (right) ->
    new Monarch.Relations.Union(this, right)

  difference: (right) ->
    new Monarch.Relations.Difference(this, right)

  limit: (limitCount, offsetCount) ->
    operand = if offsetCount
      @offset(offsetCount)
    else
      this
    new Monarch.Relations.Limit(operand, limitCount)

  offset: (count) ->
    new Monarch.Relations.Offset(this, count)

  orderBy: ->
    new Monarch.Relations.OrderBy(this, _.flatten(_.toArray(arguments)))

  buildKey: (tuple) ->
    key = {}
    for orderByExpression in @orderByExpressions
      columnName = orderByExpression.columnName
      key[columnName] = tuple.getFieldValue(columnName)
    key

  buildOrderByExpressions: (orderByStrings) ->
    orderByStrings = orderByStrings.concat(['id'])
    for orderByString in orderByStrings
      new Monarch.Expressions.OrderBy(this, orderByString)

  resolvePredicate: (object) ->
    if object instanceof Monarch.Expressions.Predicate
      return object.resolve(this)

    predicates = (@predicateForKeyValue(key, value) for key, value of object)
    _.inject predicates, (left, right) -> left.and(right)

  predicateForKeyValue: (key, value) ->
    parts = key.split(" ")
    if parts[1]
      key = parts[0]
      predicateClass = Monarch.Expressions.Predicate.forSymbol(parts[1])
    else
      predicateClass = Monarch.Expressions.Equal

    new predicateClass(key, value).resolve(this)

  activate: ->
    @_activate() unless @isActive

  _activate: ->
    @_insertNode = new Monarch.Util.Node()
    @_updateNode = new Monarch.Util.Node()
    @_removeNode = new Monarch.Util.Node()
    @_insertNode.onEmpty => @deactivateIfNeeded()
    @_updateNode.onEmpty => @deactivateIfNeeded()
    @_removeNode.onEmpty => @deactivateIfNeeded()
    @subscriptions = new Monarch.Util.SubscriptionBundle()
    @isActive = true

  deactivateIfNeeded: ->
    @deactivate() unless @hasSubscriptions()

  deactivate: ->
    delete @_insertNode
    delete @_updateNode
    delete @_removeNode
    @subscriptions.destroy()
    @isActive = false

  subscribe: (operand, event, callback) ->
    @subscriptions.add(operand[event](callback, this))

  subscriptionCount: ->
    return 0 unless @isActive
    @_insertNode.size() + @_updateNode.size() + @_removeNode.size()

  hasSubscriptions: ->
    @subscriptionCount() > 0
