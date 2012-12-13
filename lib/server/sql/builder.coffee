module.exports = ({ Monarch, _ }) ->

  class Monarch.Sql.Builder
    visit: Monarch.Util.Visitor.visit

    visit_Relations_Table: (r) ->
      tableRef = new Monarch.Sql.TableRef(r.resourceName())
      columns = (@visit(column) for column in r.columns())
      new Monarch.Sql.Query(select: columns, from: tableRef)

    visit_Relations_Selection: (r) ->
      _.tap(@visit(r.operand), (query) =>
        query.condition = @visit(r.predicate))

    visit_Relations_OrderBy: (r) ->
      _.tap(@visit(r.operand), (query) =>
        query.orderByExpressions = r.orderByExpressions.map (e) => @visit(e))

    visit_Relations_Limit: (r) ->
      _.tap(@visit(r.operand), (query) =>
        query.limitCount = r.count)

    visit_Relations_Offset: (r) ->
      _.tap(@visit(r.operand), (query) =>
        query.offsetCount = r.count)

    visit_Relations_Union: (r) ->
      new Monarch.Sql.Union(@visit(r.left), @visit(r.right))

    visit_Relations_Difference: (r) ->
      new Monarch.Sql.Difference(@visit(r.left), @visit(r.right))

    visit_Relations_InnerJoin: (r) ->
      leftQuery = @visit(r.left)
      rightQuery = @visit(r.right)
      condition = @visit(r.predicate)

      new Monarch.Sql.Query(
        select: leftQuery.select.concat(rightQuery.select)
        from: new Monarch.Sql.JoinTableRef(
          leftQuery.from,
          rightQuery.from,
          condition))

    visit_Relations_Projection: (r) ->
      table = r.table
      columns = (@visit(column) for column in table.columns())
      _.tap(@visit(r.operand), (query) -> query.select = columns)

    visit_Expressions_And: (e) ->
      visitBinaryOperator.call(this, e, "AND")

    visit_Expressions_Equal: (e) ->
      visitBinaryOperator.call(this, e, "=")

    visit_Expressions_Column: (e) ->
      new Monarch.Sql.Column(e.table.resourceName(), e.resourceName())

    visit_Expressions_OrderBy: (e) ->
      new Monarch.Sql.OrderByExpression(
        e.column.table.resourceName(),
        e.column.resourceName(),
        directionString(e.directionCoefficient))

    visit_String: (e) ->
      new Monarch.Sql.StringLiteral(e)

    visit_Boolean: (e) ->
      new Monarch.Sql.Literal(e)

    visit_Number: (e) ->
      new Monarch.Sql.Literal(e)

  visitBinaryOperator = (e, operator) ->
    new Monarch.Sql.BinaryOperator(
      @visit(e.left),
      @visit(e.right),
      operator)

  directionString = (coefficient) ->
    if (coefficient == -1) then 'DESC' else 'ASC'
