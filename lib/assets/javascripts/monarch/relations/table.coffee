class Monarch.Relations.Table extends Monarch.Relations.Relation
  constructor: (@recordClass) ->
    @name = recordClass.tableName or recordClass.name
    @remoteName = _.underscoreAndPluralize(recordClass.name)
    @columnsByName = {}
    @column('id', 'integer')
    @defaultOrderBy('id')
    @activate()

  column: (name, type) ->
    @columnsByName[name] = new Monarch.Expressions.Column(this, name, type)

  syntheticColumn: (name, definition) ->
    @columnsByName[name] = new Monarch.Expressions.SyntheticColumn(this, name, definition)

  getColumn: (name) ->
    parts = name.split('.')
    if parts.length == 2
      return if parts[0] != @name
      name = parts[1]
    @columnsByName[name]

  columns: ->
    _.values(@columnsByName)

  eachColumn: (f, ctx) ->
    _.each(@columnsByName, f, ctx)

  defaultOrderBy: ->
    @orderByExpressions = @buildOrderByExpressions(_.toArray(arguments))
    @_contents = @buildContents()

  buildContents: ->
    new Monarch.Util.SkipList(@buildComparator())

  inferJoinColumns: (columns) ->
    for column in columns
      name = column.name
      match = name.match(/^(.+)Id$/)
      if match and _.camelize(match[1]) == @name
        return [@getColumn('id'), columns[i]]

  deactivateIfNeeded: -> # no-op

  update: (recordsById) ->
    for id, attributes of recordsById
      id = parseInt(id)
      localAttributes = {}
      for name, value of attributes
        localAttributes[_.camelize(name, true)] = value

      existingRecord = @find(id)
      if existingRecord
        existingRecord.updated(localAttributes)
      else
        localAttributes.id = id
        @recordClass.created(localAttributes)

  clear: ->
    @_insertNode.clear()
    @_updateNode.clear()
    @_removeNode.clear()
    @_contents = new Monarch.Util.SkipList(@buildComparator())

  wireRepresentation: ->
    type: 'table',
    name: @remoteName

  findOrFetch: (id) ->
    record = @find(id)
    promise = new Monarch.Util.Promise
    if record
      promise.triggerSuccess(record)
    else
      Monarch.Remote.Server.fetch(@where({ id })).onSuccess =>
        record = @find(id)
        promise.triggerSuccess(record)
    promise

  create: (args...) -> @recordClass.create(args...)
  created: (args...) -> @recordClass.created(args...)
