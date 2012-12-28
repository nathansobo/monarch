_ = require "underscore"
Nodes = require "./nodes"
QueryBuilder = require "./query_builder"
{ underscore } = require("../core").Util.Inflection

module.exports = class UpdateBuilder extends QueryBuilder
  visit_Relations_Table: (table, fieldValues) ->
    new Nodes.Update(
      @buildTableNode(table),
      buildAssignments.call(this, fieldValues))

buildAssignments = (fieldValues) ->
  for key, value of fieldValues
    column = new Nodes.InsertColumn(underscore(key))
    sqlValue = @visit(value)
    new Nodes.Assignment(column, sqlValue)

