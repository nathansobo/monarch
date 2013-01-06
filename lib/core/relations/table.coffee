class Monarch.Relations.Table extends Monarch.Relations.Relation
  { capitalize, uncapitalize } = Monarch.Util.Inflection

  constructor: (@recordClass) ->
    @name = recordClass.tableName or recordClass.name
    @columnsByName = {}
    @column('id', 'key')
    @defaultOrderBy('id')
    @initialize()

  initialize: ->

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

  inferJoinColumns: (columns) ->
    for column in columns
      name = column.name
      match = name.match(/^(.+)Id$/)
      if match and capitalize(match[1]) == @name
        return [@getColumn('id'), column]

  update: (recordsById) ->
    for id, attributes of recordsById
      id = parseInt(id)
      localAttributes = {}
      for name, value of attributes
        localAttributes[name] = value

      existingRecord = @find(id)
      if existingRecord
        existingRecord.updated(localAttributes)
      else
        localAttributes.id = id
        @recordClass.created(localAttributes)

  resourceUrl: ->
    @recordClass.resourceUrl(@name)

  resourceName: ->
    @recordClass.resourceName(@name)

  wireRepresentation: ->
    type: 'Table'
    name: @resourceName()

  build: (args...) -> new @recordClass(args...)
  create: (args...) -> @recordClass.create(args...)
  created: (args...) -> @recordClass.created(args...)
