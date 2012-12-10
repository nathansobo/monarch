module.exports = ({ Monarch, _ }) ->

  class Monarch.Sql.Query
    constructor: ({ select, from }) ->
      @select = select
      @from = from
      @condition = null
      @orderExpressions = []

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
      if not _.isEmpty(@orderExpressions)
        "ORDER BY " + @orderExpressions.map((e) -> e.toSql()).join(', ')

    limitClauseSql: ->
      if @limit
        "LIMIT " + @limit

    offsetClauseSql: ->
      if @offset
        "OFFSET " + @offset

    canHaveJoinAdded: ->
      !(@condition? || @limit?)

    canHaveOrderByAdded: ->
      !(@limit?)
