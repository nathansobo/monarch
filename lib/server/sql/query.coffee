module.exports = ({ Monarch, _ }) ->

  class Monarch.Sql.Query extends Monarch.Base
    constructor: (source, columns) ->
      @setSource(source)
      @setColumns(columns)
      @setCondition(null)
      @setOrderExpressions([])

    @accessors 'source', 'columns', 'condition', 'orderExpressions',
               'limit', 'offset'

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
      parts = @columns().map (columnRef) -> columnRef.toSelectClauseSql()
      "SELECT " + parts.join(', ')

    fromClauseSql: ->
      "FROM " + @source().toSql()

    whereClauseSql: ->
      "WHERE " + @condition().toSql() if @condition()

    orderByClauseSql: ->
      if not _.isEmpty(@orderExpressions())
        "ORDER BY " + @orderExpressions().map((e) -> e.toSql()).join(', ')

    limitClauseSql: ->
      if @limit()
        "LIMIT " + @limit()

    offsetClauseSql: ->
      if @offset()
        "OFFSET " + @offset()

    canHaveJoinAdded: ->
      !(@condition()? || @limit()?)

    canHaveOrderByAdded: ->
      !(@limit()?)
