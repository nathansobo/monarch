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
      tableRef = new Monarch.Sql.TableRef(r.resourceName())
      columns = (@visit(column, tableRef) for column in r.columns())
      new Monarch.Sql.Query(select: columns, from: tableRef)

    visit_Relations_Selection: (r) ->
      _.tap(@visit(r.operand), (query) =>
        query.condition = @visit(r.predicate, query.from))

    visit_Relations_OrderBy: (r) ->
      _.tap(@visit(r.operand), (query) =>
        query.orderByExpressions = (@visit(e) for e in r.orderByExpressions))

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
      components = for side in ['left', 'right']
        query = @visit(r[side])
        if query.canHaveJoinAdded()
          from = query.from
          select = query.select
        else
          from = buildSubquery.call(this, query)
          select = from.selectList()
        { from, select }

      select = (components[0].select).concat(components[1].select)
      join = new Monarch.Sql.JoinTableRef(components[0].from, components[1].from)
      join.condition = @visit(r.predicate, join)
      new Monarch.Sql.Query({ select, from: join })

    visit_Relations_Projection: (r) ->
      _.tap(@visit(r.operand), (query) =>
        columns = (@visit(column, query.from) for column in r.table.columns())
        query.select = columns)

    visit_Expressions_And: visitBinaryOperator("AND")
    visit_Expressions_Equal: visitBinaryOperator("=")

    visit_Expressions_Column: (e, tableRef) ->
      new Monarch.Sql.Column(
        tableRef,
        e.table.resourceName()
        e.resourceName())

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

  buildSubquery = (query) ->
    new Monarch.Sql.Subquery(query, ++@subqueryIndex)

  directionString = (coefficient) ->
    if (coefficient == -1) then 'DESC' else 'ASC'
