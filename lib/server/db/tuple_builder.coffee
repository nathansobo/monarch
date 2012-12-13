module.exports = ({ Monarch, _ }) ->

  { convertKeysToCamelCase } = Monarch.Util.Inflection

  Monarch.Db.TupleBuilder =
    visit: Monarch.Util.Visitor.visit

    visit_Relations_Table: (r, row) ->
      new r.recordClass(convertKeysToCamelCase(row))

    visit_Relations_Selection: (r, row) ->
      @visit(r.operand, row)

    visit_Relations_OrderBy: (r, row) ->
      @visit(r.operand, row)

    visit_Relations_Offset: (r, row) ->
      @visit(r.operand, row)

    visit_Relations_InnerJoin: (r, row) ->
      new Monarch.CompositeTuple(
        @visit(r.left, row),
        @visit(r.right, row))

    visit_Relations_Projection: (r, row) ->
      @visit(r.table, row)
