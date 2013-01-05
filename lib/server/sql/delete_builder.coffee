Nodes = require "./nodes"
QueryBuilder = require "./query_builder"

class DeleteBuilder extends QueryBuilder
  visit_Relations_Table: (table, fieldValues) ->
    new Nodes.Delete(@buildTableNode(table))

module.exports = DeleteBuilder
