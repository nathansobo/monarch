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

