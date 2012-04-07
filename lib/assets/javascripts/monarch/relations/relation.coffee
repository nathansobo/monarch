class Monarch.Relations.Relation extends Monarch.Base
  contents: ->
    if @isActive
      unless @_contents
        @_contents = new Monarch.Util.SkipList(@buildComparator())
        for tuple in @_all()
          @insert(tuple)
      @_contents
    else
      contents = new Monarch.Util.SkipList(@buildComparator())
      for tuple in @_all()
        contents.insert(@buildKey(tuple), tuple)
      contents

  all: ->
    if @_contents
      @_contents.values()
    else
      @_all()

  size: ->
    @all().length

  fetch: ->
    Monarch.Remote.Server.fetch(this)

  insert: (tuple, newKey, oldKey) ->
    newKey ?= @buildKey(tuple)
    index = @contents().insert(newKey, tuple)
    @_insertNode.publish(tuple, index, newKey, oldKey or newKey)

  tupleUpdated: (tuple, changeset, newKey, oldKey) ->
    oldIndex = @contents().remove(oldKey)
    newIndex = @contents().insert(newKey, tuple)
    @_updateNode.publish(tuple, changeset, newIndex, oldIndex, newKey, oldKey)

  remove: (tuple, newKey, oldKey, changeset) ->
    newKey ?= oldKey = @buildKey(tuple)
    index = @contents().remove(oldKey)
    @_removeNode.publish(tuple, index, newKey, oldKey, changeset)

  isEmpty: ->
    @all().length == 0

  contains: (tuple) ->
    @indexOf(tuple) != -1

  indexOf: (tuple) ->
    @contents().indexOf(@buildKey(tuple))

  containsKey: (keys...) ->
    _.any keys, (key) => @contents().indexOf(key) != -1

  findByKey: (key) ->
    @contents().find(key)

  find: (idOrPredicate) ->
    predicate = if _.isObject(idOrPredicate)
      idOrPredicate
    else
      { id: idOrPredicate }
    @where(predicate).first()

  at: (index) ->
    @contents().at(index)

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

  joinThrough: (table) ->
    @join(table).project(table)

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

  buildComparator: (compareRecords) ->
    # null is treated like infinity
    lessThan = (a, b) ->
      return false if (a == null or a == undefined) and b != null and b != undefined
      return true if (b == null or b == undefined) and a != null and a != undefined
      return a < b

    orderByExpressions = @orderByExpressions
    (a, b) ->
      for orderByExpression in orderByExpressions
        columnName = orderByExpression.columnName
        directionCoefficient = orderByExpression.directionCoefficient
        if compareRecords
          aValue = a.getFieldValue(columnName)
          bValue = b.getFieldValue(columnName)
        else
          aValue = a[columnName]
          bValue = b[columnName]

        if lessThan(aValue, bValue)
          return -1 * directionCoefficient
        else if lessThan(bValue, aValue)
          return 1 * directionCoefficient
      0

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
    @contents(); # cause contents to memoize

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
