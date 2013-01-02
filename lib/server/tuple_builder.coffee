{ Util, CompositeTuple } = require("./core")
{ Inflection, Visitor } = Util
{ camelize } = Inflection

visitProperty = (name) ->
  (r, rows) ->
    @visit(r[name], rows)

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

  visit_Relations_Limit: visitProperty('operand')
  visit_Relations_Offset: visitProperty('operand')
  visit_Relations_OrderBy: visitProperty('operand')
  visit_Relations_Selection: visitProperty('operand')
  visit_Relations_Union: visitProperty('left')
  visit_Relations_Difference: visitProperty('left')
  visit_Relations_Projection: visitProperty('table')

