class Monarch.Record
  { singularize, capitalize, uncapitalize, underscoreAndPluralize } = Monarch.Util.Inflection

  @extended: (subclass) ->
    subclass.table = Monarch.Repository.buildTable(subclass)
    subclass.defineColumnAccessor('id')

  @resourceUrl: (name) ->
    Monarch.resourceUrlRoot + '/' + @resourceName(name)

  @resourceName: (name) ->
    underscoreAndPluralize(uncapitalize(name)).replace(/_/g, Monarch.resourceUrlSeparator)

  @column: (name, type) ->
    @table.column(name, type)
    @defineColumnAccessor(name)
    this

  @columns: (hash) ->
    for name, type of hash
      @column(name, type)
    this

  @syntheticColumn: (name, definition) ->
    @table.syntheticColumn(name, definition)
    @prototype[name] = -> @getFieldValue(name)
    this

  @hasMany: (name, options={}) ->
    targetClassName = options.className ? singularize(capitalize(name))
    foreignKey = options.foreignKey ? uncapitalize(@table.name) + "Id"

    @relatesTo name, ->
      target = Monarch.Repository.tables[targetClassName]
      conditions = _.extend({}, options.conditions or {})

      if options.through
        target = this[options.through]().joinThrough(target)
      else
        conditions[foreignKey] = @id()

      relation = target.where(conditions)
      if options.orderBy
        relation.orderBy(options.orderBy)
      else
        relation

  @relatesTo: (name, definition) ->
    @prototype[name] = ->
      @_associations[name] ?= definition.call(this)
    this

  @belongsTo: (name, options={}) ->
    targetClassName = options.className ? capitalize(name)
    foreignKey = options.foreignKey ? name + "Id"
    @prototype[name] = ->
      target = Monarch.Repository.tables[targetClassName]
      target.find(this[foreignKey]())
    this

  @defaultOrderBy: ->
    @table.defaultOrderBy.apply(@table, arguments)
    this

  @create: (attributes) ->
    record = new this(attributes)
    record.save()

  @created: (attributes) ->
    record = new this()
    record.created(attributes)
    record

  @defineColumnAccessor: (name) ->
    @prototype[name] = ->
      field = @getField(name)
      if arguments.length == 0
        field.getValue()
      else
        field.setValue(arguments[0])

  for methodName in ['table', 'wireRepresentation', 'contains', 'onUpdate', 'onInsert', 'onRemove',
    'at', 'indexOf', 'where', 'join', 'union', 'difference', 'limit', 'offset', 'orderBy',
    'hasSubscriptions', 'find', 'size', 'getColumn', 'all', 'each', 'first', 'last', 'fetch', 'clear', 'findOrFetch']
    do (methodName) =>
      this[methodName] = (args...) ->
        @table[methodName](args...)

  constructor: (attributes) ->
    @table = @constructor.table
    @errors = new Monarch.Errors()
    @_associations = {}
    @localFields = {}
    @remoteFields = {}

    @table.eachColumn (column) =>
      @localFields[column.name] = column.buildLocalField(this)
      @remoteFields[column.name] = column.buildRemoteField(this)

    @localUpdate(attributes) if attributes
    @afterInitialize()

  afterInitialize: _.identity,
  beforeCreate: _.identity,
  afterCreate: _.identity,
  beforeUpdate: _.identity,
  afterUpdate: _.identity,
  beforeDestroy: _.identity,
  afterDestroy: _.identity,

  getField: (name) ->
    parts = name.split('.')
    if parts.length > 1
      if parts[0] == @table.name
        name = parts[1]
      else
        return undefined

    @localFields[name]

  getFieldValue: (name) ->
    @getField(name).getValue()

  getRemoteField: (name) ->
    @remoteFields[name]

  update: (attributes) ->
    @localUpdate(attributes)
    @save()

  localUpdate: (attributes) ->
    for name, value of attributes
      this[name]?(value)

  onUpdate: (callback, context) ->
    @onUpdateNode ?= new Monarch.Util.Node()
    @onUpdateNode.subscribe(callback, context)

  onDestroy: (callback, context) ->
    @onDestroyNode ?= new Monarch.Util.Node()
    @onDestroyNode.subscribe(callback, context)

  wireRepresentation: (allFields) ->
    @fieldValues(true, allFields)

  fieldValues: (wireRepresentation, allFields) ->
    fieldValues = {}
    for name, field of @localFields
      if wireRepresentation
        if (allFields or field.isDirty()) and not (field instanceof Monarch.SyntheticField)
          fieldValues[name] = field.wireRepresentation()
      else
        fieldValues[name] = field.getValue()
    fieldValues

  created: (attributes) ->
    @updated(attributes)
    @table.insert(this)
    @afterCreate()

  updated: (attributes) ->
    newRecord = not @id()
    changeset = @pendingChangeset = {}
    oldKey = @table.buildKey(this)

    for name, value of attributes
      @getRemoteField(name)?.setValue(value)

    newKey = @table.buildKey(this)
    delete @pendingChangeset

    unless newRecord or _.isEmpty(changeset)
      @table.tupleUpdated(this, changeset, newKey, oldKey)

    @afterUpdate()
    @onUpdateNode?.publish(changeset)
    changeset

  destroyed: ->
    @table.remove(this)
    @afterDestroy()
    @onDestroyNode?.publish()

  isValid: ->
    @errors.isEmpty()

  isDirty: ->
    _.any @localFields, (field) -> field.isDirty()

  isEqual: (other) ->
    (@constructor == other.constructor) and (@id() == other.id())

  save: ->
    if @id()
      return if @beforeUpdate() == false
      Monarch.Remote.Server.update(this, @wireRepresentation())
    else
      return if @beforeCreate() == false
      Monarch.Remote.Server.create(this, @wireRepresentation())

  fetch: ->
    @table.where({ id: @id() }).fetch()

  destroy: ->
    return if @beforeDestroy() == false
    Monarch.Remote.Server.destroy(this)

  signal: (fieldNames..., transformer) ->
    unless _.isFunction(transformer)
      fieldNames.push(transformer)
      transformer = undefined

    fields = for name in fieldNames
      if @remoteSignals
        @getRemoteField(name)
      else
        @getField(name)

    new Monarch.Util.Signal(fields, transformer)

  getRecord: (tableName) ->
    this if @table.name == tableName

  toString: ->
    "<" + @constructor.displayName + " " + JSON.stringify(@fieldValues()) + ">"
