class Monarch.Record extends Monarch.Base
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
    record = new this(attributes)
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
    'find', 'size', 'getColumn', 'all', 'each', 'first', 'last', 'clear']
    do (methodName) =>
      this[methodName] = (args...) ->
        @table[methodName](args...)

  constructor: (attributes={}) ->
    @table = @constructor.table
    @errors = new Monarch.Errors()
    @_associations = {}
    @localFields = {}
    @remoteFields = {}

    @table.eachColumn (column) =>
      @localFields[column.name] = column.buildLocalField(this)
      @remoteFields[column.name] = column.buildRemoteField(this)

    attributes.id ?= Monarch.Repository.generateTemporaryId()
    @localUpdate(attributes, silent: true)
    @table.insert(this)
    @afterInitialize()

  beforeSave: _.identity,
  afterInitialize: _.identity,
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

  accrueUpdates: (args...) ->
    if args.length > 1
      options = args.shift()
    else
      options = {}
    fn = args.shift()

    if @pendingChangeset
      fn()
    else
      changeset = @pendingChangeset = {}
      oldKey = @table.buildKey(this)
      value = fn()
      newKey = @table.buildKey(this)
      delete @pendingChangeset

      unless options.silent or _.isEmpty(changeset)
        @afterUpdate(changeset)
        @onUpdateNode?.publish(changeset)
        @table.tupleUpdated(this, changeset, newKey, oldKey)

      value

  localUpdate: (attributes, options={}) ->
    @accrueUpdates options, =>
      for name, value of attributes
        this[name]?(value)

  onUpdate: (callback, context) ->
    @onUpdateNode ?= new Monarch.Util.Node()
    @onUpdateNode.subscribe(callback, context)

  onDestroy: (callback, context) ->
    @onDestroyNode ?= new Monarch.Util.Node()
    @onDestroyNode.subscribe(callback, context)

  onResolved: (callback, context) ->
    if @isResolved()
      callback.apply(context)
    else
      @onResolvedNode ?= new Monarch.Util.Node()
      @onResolvedNode.subscribe(callback, context)

  isResolved: ->
    for name, field of @localFields when name != 'id'
      return false unless field.isResolved()
    true

  fieldResolved: (name, provisionalKey, newKey) ->
    if name == 'id'
      Monarch.Repository.resolveKey(provisionalKey, newKey)
    if @isResolved()
      @onResolvedNode?.publish()
      @onResolvedNode?.clear()

  wireRepresentation: (allFields) ->
    @fieldValues(true, allFields)

  fieldValues: (wireRepresentation, allFields) ->
    fieldValues = {}
    for name, field of @localFields
      if wireRepresentation
        if (allFields or field.isDirty()) and not (field instanceof Monarch.SyntheticField)
          fieldValues[name] = field.wireRepresentation()
      else
        fieldValues[name] = field.getValue() ? null
    fieldValues

  created: (attributes) ->
    @updated(attributes)

  updated: (attributes) ->
    @accrueUpdates =>
      for name, value of attributes
        @getRemoteField(name)?.setValue(value)
      @pendingChangeset

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
