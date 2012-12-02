class Monarch.Expressions.Column
  constructor: (@table, @name, @type) ->
    @qualifiedName = @table.name + "." + @name

  buildLocalField: (record) ->
    new Monarch.LocalField(record, this)

  buildRemoteField: (record) ->
    new Monarch.RemoteField(record, this)

  eq: (right) ->
    new Monarch.Expressions.Equal(this, right)

  wireRepresentation: ->
    type: 'Column',
    table: @table.resourceName(),
    name: @resourceName()

  resourceName: ->
    Monarch.Util.Inflection.underscore(@name).replace(/_/g, Monarch.resourceUrlSeparator)

  normalizeValue: (value) ->
    if @type == 'datetime' and _.isNumber(value)
      new Date(value)
    else
      value

  valueWireRepresentation: (value) ->
    if @type == 'datetime' and value
      value?.getTime() ? value
    else
      value
