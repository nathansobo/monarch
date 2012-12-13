module.exports = ({ Monarch, _ }) ->

  visitBinaryOperator = (operator) ->
    (e, args...) ->
      new Monarch.Sql.BinaryOperator(
        @visit(e.left, args...),
        @visit(e.right, args...),
        operator)

  class Monarch.Sql.Builder
    constructor: ->
      @subqueryIndex = 0

    visit: Monarch.Util.Visitor.visit

    visit_Relations_Table: (r) ->
      table = new Monarch.Sql.Table(r.resourceName())
      columns = (@visit(column, table) for column in r.columns())
      new Monarch.Sql.Query(table, columns)

    visit_Relations_Selection: (r) ->
      _.tap @visit(r.operand), (query) =>
        query.setCondition(@visit(r.predicate, query.source()))

    visit_Relations_OrderBy: (r) ->
      operandQuery = @visit(r.operand)
      query = if operandQuery.canHaveOrderByAdded()
        operandQuery
      else
        wrapQuery(this, operandQuery)
      _.tap query, (query) =>
        query.setOrderExpressions(
          @visit(e, query.source()) for e in r.orderByExpressions)

    visit_Relations_Limit: (r) ->
      _.tap @visit(r.operand), (query) ->
        query.setLimit(r.count)

    visit_Relations_Offset: (r) ->
      _.tap @visit(r.operand), (query) ->
        query.setOffset(r.count)

    visit_Relations_Union: (r) ->
      new Monarch.Sql.Union(@visit(r.left), @visit(r.right))

    visit_Relations_Difference: (r) ->
      new Monarch.Sql.Difference(@visit(r.left), @visit(r.right))

    visit_Relations_InnerJoin: (r) ->
      sideQueries = for side in ['left', 'right']
        operandQuery = @visit(r[side])
        if operandQuery.canHaveJoinAdded()
          operandQuery
        else
          wrapQuery(this, operandQuery)
      select = (sideQueries[0].columns()).concat(sideQueries[1].columns())
      join = new Monarch.Sql.Join(sideQueries[0].source(), sideQueries[1].source())
      join.condition = @visit(r.predicate, join)
      new Monarch.Sql.Query(join, select)

    visit_Relations_Projection: (r) ->
      _.tap @visit(r.operand), (query) =>
        query.setColumns(
          @visit(column, query.source()) for column in r.table.columns())

    visit_Expressions_And: visitBinaryOperator("AND")
    visit_Expressions_Equal: visitBinaryOperator("=")

    visit_Expressions_Column: (e, source) ->
      new Monarch.Sql.Column(source, e.table.resourceName(), e.resourceName())

    visit_Expressions_OrderBy: (e, source) ->
      new Monarch.Sql.OrderExpression(
        @visit(e.column, source),
        directionString(e.directionCoefficient))

    visit_String: (e) ->
      new Monarch.Sql.StringLiteral(e)

    visit_Boolean: (e) ->
      new Monarch.Sql.Literal(e)

    visit_Number: (e) ->
      new Monarch.Sql.Literal(e)

  wrapQuery = (builder, query) ->
    subquery = new Monarch.Sql.Subquery(query, ++builder.subqueryIndex)
    new Monarch.Sql.Query(subquery, subquery.allColumns())

  directionString = (coefficient) ->
    if (coefficient == -1) then 'DESC' else 'ASC'
