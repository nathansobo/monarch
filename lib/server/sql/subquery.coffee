module.exports = ({ Monarch, _ }) ->

  class Monarch.Sql.Subquery
    constructor: (@query, index) ->
      @name = "t" + index

    resolveColumnName: (tableName, columnName) ->
      innerNames = @query.from.resolveColumnName(tableName, columnName)
      if innerNames
        {
          tableName: @name,
          columnName: Monarch.Sql.Column.aliasName(
            innerNames.tableName,
            innerNames.columnName),
          needsAlias: false,
        }

    selectList: ->
      for column in @query.select
        new Monarch.Sql.Column(this, column.tableName, column.name)

    toSql: ->
      "( #{@query.toSql()} ) as \"#{@name}\""
