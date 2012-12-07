module.exports = ({ Monarch, _ }) ->

  Monarch.Db.TupleBuilder =
    visit: Monarch.Util.Visitor.visit

    visit_Relations_Table: (r, rows) ->
      return [] if rows.length == 0
      nameMap = buildFieldNameMap(rows[0], r.resourceName())
      new r.recordClass(mapFieldNames(row, nameMap)) for row in rows

    visit_Relations_Selection: (r, rows) ->
      @visit(r.operand, rows)

    visit_Relations_OrderBy: (r, rows) ->
      @visit(r.operand, rows)

    visit_Relations_Offset: (r, rows) ->
      @visit(r.operand, rows)

    visit_Relations_InnerJoin: (r, rows) ->
      leftRecords = @visit(r.left, rows)
      rightRecords = @visit(r.right, rows)
      for leftRecord, i in leftRecords
        new Monarch.CompositeTuple(leftRecord, rightRecords[i])

    visit_Relations_Projection: (r, rows) ->
      @visit(r.table, rows)

  { camelize } = Monarch.Util.Inflection

  buildFieldNameMap = (row, thisTableName) ->
    nameMap = {}
    for qualifiedColumnName of row
      [tableName, columnName] = qualifiedColumnName.split("__")
      if (tableName is thisTableName)
        nameMap[camelize(columnName)] = qualifiedColumnName
    nameMap

  mapFieldNames = (row, nameMap) ->
    fieldValues = {}
    for fieldName, qualifiedColumnName of nameMap
      fieldValues[fieldName] = row[qualifiedColumnName]
    fieldValues
