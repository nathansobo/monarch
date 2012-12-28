Nodes = require "./nodes"
QueryBuilder = require "./query_builder"

module.exports = class DeleteBuilder extends QueryBuilder
  visit_Relations_Table: (table, fieldValues) ->
    new Nodes.Delete(@buildTableNode(table))

