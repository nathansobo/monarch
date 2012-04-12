class Monarch.Expressions.Column
  constructor: (@table, @name, @type) ->
    @remoteName = _.underscore(name)
    @qualifiedName = @table.name + "." + @name

  buildLocalField: (record) ->
    new Monarch.LocalField(record, this)

  buildRemoteField: (record) ->
    new Monarch.RemoteField(record, this)

  eq: (right) ->
    new Monarch.Expressions.Equal(this, right)

  wireRepresentation: ->
    type: 'column',
    table: @table.remoteName,
    name: @remoteName

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
