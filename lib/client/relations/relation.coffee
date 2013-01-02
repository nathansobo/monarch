Monarch.Relations.Relation.reopen ->
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
    Monarch.RecordRetriever.retrieveRecords(this)

  onInsert: (callback, context) ->
    Monarch.Events.onInsert(this, callback, context)

  onUpdate: (callback, context) ->
    Monarch.Events.onUpdate(this, callback, context)

  onRemove: (callback, context) ->
    Monarch.Events.onRemove(this, callback, context)

  insert: (tuple, newKey, oldKey) ->
    newKey ?= @buildKey(tuple)
    index = @contents().insert(newKey, tuple)
    Monarch.Events.publishInsert(this, tuple, index, newKey, oldKey or newKey)

  tupleUpdated: (tuple, changeset, newKey, oldKey) ->
    oldIndex = @contents().remove(oldKey)
    newIndex = @contents().insert(newKey, tuple)
    Monarch.Events.publishUpdate(this, tuple, changeset, newIndex, oldIndex, newKey, oldKey)

  remove: (tuple, newKey, oldKey, changeset) ->
    newKey ?= oldKey = @buildKey(tuple)
    index = @contents().remove(oldKey)
    Monarch.Events.publishRemove(this, tuple, index, newKey, oldKey, changeset)

  indexOf: (tuple) ->
    @contents().indexOf(@buildKey(tuple))

  containsKey: (keys...) ->
    _.any keys, (key) => @contents().indexOf(key) != -1

  at: (index) ->
    @contents().at(index)

  findByKey: (key) ->
    @contents().find(key)

  buildKey: (tuple) ->
    key = {}
    for orderByExpression in @orderByExpressions
      columnName = orderByExpression.columnName
      key[columnName] = tuple.getFieldValue(columnName)
    key

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

  fetch: ->
    Monarch.Remote.Server.fetch(this)
