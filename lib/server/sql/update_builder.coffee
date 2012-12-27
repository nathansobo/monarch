_ = require "underscore"
Nodes = require "./nodes"
QueryBuilder = require "./query_builder"
{ underscore } = require("../core").Util.Inflection

module.exports = class UpdateBuilder extends QueryBuilder
  buildQuery: (table, fieldValues) ->
    new Nodes.Update(
      buildTable(table),
      buildAssignments.call(this, fieldValues))

buildTable = (table) ->
  new Nodes.Table(table.resourceName())

buildAssignments = (fieldValues) ->
  for key, value of fieldValues
    column = new Nodes.InsertColumn(underscore(key))
    sqlValue = @visit(value)
    new Nodes.Assignment(column, sqlValue)

