module.exports = ({ Monarch, _ }) ->

  class Monarch.Sql.Subquery
    constructor: (@query, index) ->
      @name = "t" + index

    resolveColumnName: (tableName, columnName) ->
      innerNames = @query.source().resolveColumnName(tableName, columnName)
      if innerNames
        {
          tableName: @name,
          columnName: Monarch.Sql.Column.aliasName(
            innerNames.tableName,
            innerNames.columnName),
          needsAlias: false,
        }

    allColumns: ->
      for column in @query.columns()
        new Monarch.Sql.Column(this, column.tableName, column.name)

    toSql: ->
      "( #{@query.toSql()} ) as \"#{@name}\""
