_ = require "underscore"
Nodes = require "./nodes"
QueryBuilder = require "./query_builder"

module.exports = class SelectBuilder extends QueryBuilder
  constructor: ->
    @subqueryIndex = 0

  visit_Relations_Table: (r) ->
    table = new Nodes.Table(r.resourceName())
    columns = (@visit(column, table) for column in r.columns())
    new Nodes.Select(table, columns)

  visit_Relations_Selection: (r) ->
    _.tap @visit(r.operand), (query) =>
      query.setCondition(@visit(r.predicate, query.table()))

  visit_Relations_OrderBy: (r) ->
    operandQuery = @visit(r.operand)
    query = if operandQuery.canHaveOrderByAdded()
      operandQuery
    else
      wrapQuery(this, operandQuery)
    _.tap query, (query) =>
      query.setOrderExpressions(
        @visit(e, query.table()) for e in r.orderByExpressions)

  visit_Relations_Limit: (r) ->
    _.tap @visit(r.operand), (query) ->
      query.setLimit(r.count)

  visit_Relations_Offset: (r) ->
    _.tap @visit(r.operand), (query) ->
      query.setOffset(r.count)

  visit_Relations_Union: (r) ->
    new Nodes.Union(@visit(r.left), @visit(r.right))

  visit_Relations_Difference: (r) ->
    new Nodes.Difference(@visit(r.left), @visit(r.right))

  visit_Relations_InnerJoin: (r) ->
    sideQueries = for side in ['left', 'right']
      operandQuery = @visit(r[side])
      if operandQuery.canHaveJoinAdded?()
        operandQuery
      else
        wrapQuery(this, operandQuery)
    select = (sideQueries[0].columns()).concat(sideQueries[1].columns())
    join = new Nodes.Join(sideQueries[0].table(), sideQueries[1].table())
    join.condition = @visit(r.predicate, join)
    new Nodes.Select(join, select)

  visit_Relations_Projection: (r) ->
    _.tap @visit(r.operand), (query) =>
      query.setColumns(
        @visit(column, query.table()) for column in r.table.columns())

  visit_Expressions_OrderBy: (e, table) ->
    new Nodes.OrderExpression(
      @visit(e.column, table),
      directionString(e.directionCoefficient))

wrapQuery = (builder, query) ->
  subquery = new Nodes.Subquery(query, ++builder.subqueryIndex)
  new Nodes.Select(subquery, subquery.allColumns())

directionString = (coefficient) ->
  if (coefficient == -1) then 'DESC' else 'ASC'
