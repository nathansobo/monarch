{ capitalize } = Monarch.Util.Inflection

Monarch.Repository =
  tables: {}
  pauseCount: 0

  buildTable: (recordClass) ->
    table = new Monarch.Relations.Table(recordClass)
    @tables[table.name] = table

  update: (hashOrArray) ->
    if @pauseCount > 0
      @deferredUpdates.push(hashOrArray)
      return

    if _.isArray(hashOrArray) # commands array
      if (!_.isArray(hashOrArray[0])) # allow single commands
        hashOrArray = [hashOrArray]

      for command in hashOrArray
        operation = this['perform' + capitalize(command.shift())]
        operation.apply(this, command)
    else # records hash
      for tableName, recordsHash of hashOrArray
        @tables[tableName].update(recordsHash)

  isPaused: ->
    @pauseCount > 0

  pauseUpdates: ->
    @deferredUpdates = [] if @pauseCount == 0
    @pauseCount++

  resumeUpdates: ->
    @pauseCount--
    if @pauseCount == 0
      @update(updateArg) for updateArg in @deferredUpdates
      delete @deferredUpdates

  performCreate: (tableName, attributes) ->
    table = @tables[tableName]
    return if table.find(attributes.id)
    table.recordClass.created(attributes)

  performUpdate: (tableName, id, attributes) ->
    table = @tables[tableName]
    record = table.find(parseInt(id))
    record?.updated(attributes)

  performDestroy: (tableName, id) ->
    table = @tables[tableName]
    record = table.find(parseInt(id))
    record?.destroyed()

  clear: ->
    @pauseCount = 0
    delete @deferredUpdates
    table.clear() for name, table of @tables
