_ = require "underscore"
Nodes = require "./nodes"
Visitor = require("../core").Util.Visitor

visitPrimitive = (nodeClass) ->
  (value) -> new nodeClass(value)

class QueryBuilder
  buildQuery: Visitor.visit
  visit: Visitor.visit

  visit_Boolean: visitPrimitive(Nodes.Literal)
  visit_Number: visitPrimitive(Nodes.Literal)
  visit_String: visitPrimitive(Nodes.StringLiteral)
  visit_null: visitPrimitive(Nodes.Null)

  visit_Relations_Selection: (r, args...) ->
    _.tap @visit(r.operand, args...), (query) =>
      query.setCondition(@visit(r.predicate, query.table()))

  visit_Expressions_And: (e, table) ->
    new Nodes.And(@visit(e.left, table), @visit(e.right, table))

  visit_Expressions_Equal: (e, table) ->
    new Nodes.Equals(@visit(e.left, table), @visit(e.right, table))

  visit_Expressions_Column: (e, table) ->
    new Nodes.Column(table, e.table.resourceName(), e.resourceName())

  buildTableNode: (table) ->
    new Nodes.Table(table.resourceName())

module.exports = QueryBuilder
