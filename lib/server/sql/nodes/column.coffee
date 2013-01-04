class Column
  @qualifyName: (tableName, columnName) ->
    '"' + tableName + '"."' + columnName + '"'

  @aliasName: (tableName, columnName) ->
    "#{tableName}__#{columnName}"

  constructor: (@source, @tableName, @name) ->

  toSql: ->
    { tableName, columnName } = @resolveName()
    @constructor.qualifyName(tableName, columnName)

  toSelectClauseSql: ->
    { tableName, columnName, needsAlias } = @resolveName()
    sourceName = @constructor.qualifyName(tableName, columnName)
    if needsAlias
      aliasName = @constructor.aliasName(tableName, columnName)
      "#{sourceName} as #{aliasName}"
    else
      sourceName

  resolveName: ->
    @source.resolveColumnName(@tableName, @name)

module.exports = Column
