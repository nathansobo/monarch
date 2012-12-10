module.exports = ({ Monarch, _ }) ->

  class Monarch.Sql.Table
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
