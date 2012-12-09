module.exports = ({ Monarch, _ }) ->

  class Monarch.Sql.TableRef
    constructor: (@tableName) ->

    toSql: ->
      '"' + @tableName + '"'

    resolveColumnName: (tableName, columnName) ->
      if tableName is @tableName
        {
          tableName: @tableName,
          columnName: columnName,
          needsAlias: true
        }
