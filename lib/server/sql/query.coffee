module.exports = ({ Monarch, _ }) ->

  class Monarch.Sql.Query
    constructor: ({ select, from }) ->
      @select = select
      @from = from
      @condition = null
      @orderByExpressions = []

    toSql: ->
      _.compact([
        @selectClauseSql(),
        @fromClauseSql(),
        @whereClauseSql(),
        @orderByClauseSql(),
        @limitClauseSql(),
        @offsetClauseSql()
      ]).join(' ')

    selectClauseSql: ->
      parts = @select.map (columnRef) -> columnRef.toSelectClauseSql()
      "SELECT " + parts.join(', ')

    fromClauseSql: ->
      "FROM " + @from.toSql()

    whereClauseSql: ->
      "WHERE " + @condition.toSql() if @condition

    orderByClauseSql: ->
      if not _.isEmpty(@orderByExpressions)
        "ORDER BY " + @orderByExpressions.map((e) -> e.toSql()).join(', ')

    limitClauseSql: ->
      if @limitCount
        "LIMIT " + @limitCount

    offsetClauseSql: ->
      if @offsetCount
        "OFFSET " + @offsetCount
