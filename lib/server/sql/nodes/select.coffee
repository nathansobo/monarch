_ = require "underscore"
{ Base } = require "../../core"

class Select extends Base
  constructor: (table, columns) ->
    @setTable(table)
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

  @accessors 'table', 'columns', 'condition', 'orderExpressions',
             'limit', 'offset'

  selectClauseSql: ->
    parts = (column.toSelectClauseSql() for column in @columns())
    "SELECT " + parts.join(', ')

  fromClauseSql: ->
    "FROM " + @table().toSql()

  whereClauseSql: ->
    "WHERE " + @condition().toSql() if @condition()

  orderByClauseSql: ->
    unless _.isEmpty(@orderExpressions())
      parts = (e.toSql() for e in @orderExpressions())
      "ORDER BY " + parts.join(', ')

  limitClauseSql: ->
    "LIMIT " + @limit() if @limit()

  offsetClauseSql: ->
    "OFFSET " + @offset() if @offset()

  canHaveJoinAdded: ->
    !(@condition()? || @limit()?)

  canHaveOrderByAdded: ->
    !(@limit()?)

module.exports = Select
