module.exports = ({ Monarch, _ }) ->

  class Monarch.Sql.Select extends Monarch.Base
    constructor: (source, columns) ->
      @setSource(source)
      @setColumns(columns)
      @setCondition(null)
      @setOrderExpressions([])

    toSql: ->
      _.compact([
        @selectClauseSql(),
        @fromClauseSql(),
        @whereClauseSql(),
        @orderByClauseSql(),
        @limitClauseSql(),
        @offsetClauseSql()
      ]).join(' ')

    @accessors 'source', 'columns', 'condition', 'orderExpressions',
               'limit', 'offset'

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

