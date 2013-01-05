{ capitalize, convertKeysToCamelCase, camelize, singularize } = Monarch.Util.Inflection

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
      for resourceName, recordsHash of hashOrArray
        recordsHash = convertKeysToCamelCase(recordsHash) if Monarch.snakeCase
        @tableForResourceName(resourceName).update(recordsHash)

  tableForResourceName: (resourceName) ->
    tableName = capitalize(singularize(camelize(resourceName)))
    if table = @tables[tableName]
      table
    else
      throw new Error("No table exists for resource name '#{resourceName}'")

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

  performCreate: (resourceName, attributes, extraDataset) ->
    @update(extraDataset) if extraDataset
    attributes = convertKeysToCamelCase(attributes) if Monarch.snakeCase
    table = @tableForResourceName(resourceName)
    return if table.find(attributes.id)
    table.recordClass.created(attributes)

  performUpdate: (resourceName, id, attributes) ->
    attributes = convertKeysToCamelCase(attributes) if Monarch.snakeCase
    table = @tableForResourceName(resourceName)
    record = table.find(parseInt(id))
    record?.updated(attributes)

  performDestroy: (resourceName, id) ->
    table = @tableForResourceName(resourceName)
    record = table.find(parseInt(id))
    record?.destroyed()

  clear: ->
    @pauseCount = 0
    delete @deferredUpdates
    table.clear() for name, table of @tables

  subscriptionCount: ->
    count = 0
    for name, table of @tables
      count += table.subscriptionCount()
    count
