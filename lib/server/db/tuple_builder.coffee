{ Util, CompositeTuple } = require("../core")
{ Inflection, Visitor } = Util
{ camelize } = Inflection

visitOperand = (r, rows) ->
  @visit(r.operand, rows)

visitLeftOperand = (r, rows) ->
  @visit(r.left, rows)

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

module.exports =
  visit: Visitor.visit

  visit_Relations_Table: (r, rows) ->
    return [] if rows.length == 0
    nameMap = buildFieldNameMap(rows[0], r.resourceName())
    new r.recordClass(mapFieldNames(row, nameMap)) for row in rows

  visit_Relations_InnerJoin: (r, rows) ->
    leftRecords = @visit(r.left, rows)
    rightRecords = @visit(r.right, rows)
    for leftRecord, i in leftRecords
      new CompositeTuple(leftRecord, rightRecords[i])

  visit_Relations_Limit: visitOperand
  visit_Relations_Offset: visitOperand
  visit_Relations_OrderBy: visitOperand
  visit_Relations_Selection: visitOperand
  visit_Relations_Union: visitLeftOperand
  visit_Relations_Difference: visitLeftOperand

  visit_Relations_Projection: (r, rows) ->
    @visit(r.table, rows)

