_.extend Monarch.Relations.Relation.prototype,
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

  contents: ->
    if @isActive
      unless @_contents
        @_contents = @buildContents()
        for tuple in @retrieveRecords()
          @insert(tuple)
      @_contents
    else
      contents = @buildContents()
      for tuple in @retrieveRecords()
        contents.insert(@buildKey(tuple), tuple)
      contents

  buildContents: ->
    new Monarch.Util.SkipList(@buildComparator())

  all: ->
    if @_contents
      @_contents.values()
    else
      @retrieveRecords()

  retrieveRecords: ->
    (new Monarch.Visitors.RetrieveRecords).visit(this)

  insert: (tuple, newKey, oldKey) ->
    newKey ?= @buildKey(tuple)
    index = @contents().insert(newKey, tuple)
    @_insertNode.publish(tuple, index, newKey, oldKey or newKey)

  tupleUpdated: (tuple, changeset, newKey, oldKey) ->
    oldIndex = @contents().remove(oldKey)
    newIndex = @contents().insert(newKey, tuple)
    @_updateNode.publish(tuple, changeset, newIndex, oldIndex, newKey, oldKey)

  indexOf: (tuple) ->
    @contents().indexOf(@buildKey(tuple))

  containsKey: (keys...) ->
    _.any keys, (key) => @contents().indexOf(key) != -1

  at: (index) ->
    @contents().at(index)

  findByKey: (key) ->
    @contents().find(key)

  remove: (tuple, newKey, oldKey, changeset) ->
    newKey ?= oldKey = @buildKey(tuple)
    index = @contents().remove(oldKey)
    @_removeNode.publish(tuple, index, newKey, oldKey, changeset)

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
