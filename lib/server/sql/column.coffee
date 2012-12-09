module.exports = ({ Monarch, _ }) ->

  class Monarch.Sql.Column
    @qualifyName: (tableName, columnName) ->
      '"' + tableName + '"."' + columnName + '"'

    @aliasName: (tableName, columnName) ->
      "#{tableName}__#{columnName}"

    constructor: (@source, @tableName, @name) ->

    toSql: ->
      @sourceName()

    toSelectClauseSql: ->
      if @needsAlias()
        "#{@sourceName()} as #{@aliasName()}"
      else
        @sourceName()

    aliasName: ->
      { tableName, columnName } = @resolveName()
      @constructor.aliasName(tableName, columnName)

    sourceName: ->
      { tableName, columnName } = @resolveName()
      @constructor.qualifyName(tableName, columnName)

    needsAlias: ->
      @resolveName().needsAlias

    resolveName: ->
      @_resolvedName or= @source.resolveColumnName(@tableName, @name)
