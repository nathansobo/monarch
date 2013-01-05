Column = require "./column"

class Subquery
  constructor: (@query, index) ->
    @name = "t" + index

  resolveColumnName: (tableName, columnName) ->
    innerNames = @query.table().resolveColumnName(tableName, columnName)
    if innerNames
      {
        tableName: @name,
        columnName: Column.aliasName(
          innerNames.tableName,
          innerNames.columnName),
        needsAlias: false,
      }

  allColumns: ->
    for column in @query.columns()
      new Column(this, column.tableName, column.name)

  toSql: ->
    "( #{@query.toSql()} ) as \"#{@name}\""

module.exports = Subquery
