_ = require "underscore"
Nodes = require "./nodes"
QueryBuilder = require "./query_builder"
{ underscore } = require("../core").Util.Inflection

class UpdateBuilder extends QueryBuilder
  visit_Relations_Table: (table, fieldValues) ->
    new Nodes.Update(
      @buildTableNode(table),
      buildAssignments(this, fieldValues))

buildAssignments = (builder, fieldValues) ->
  for key, value of fieldValues
    column = new Nodes.InsertColumn(underscore(key))
    sqlValue = builder.visit(value)
    new Nodes.Assignment(column, sqlValue)

module.exports = UpdateBuilder
