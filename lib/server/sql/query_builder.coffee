Nodes = require "./nodes"
Visitor = require("../core").Util.Visitor

visitPrimitive = (nodeClass) ->
  (value) -> new nodeClass(value)

module.exports = class QueryBuilder
  buildQuery: Visitor.visit
  visit: Visitor.visit

  visit_Boolean: visitPrimitive(Nodes.Literal)
  visit_Number: visitPrimitive(Nodes.Literal)
  visit_String: visitPrimitive(Nodes.StringLiteral)
  visit_null: visitPrimitive(Nodes.Null)

  visit_Expressions_And: (e, source) ->
    new Nodes.And(@visit(e.left, source), @visit(e.right, source))

  visit_Expressions_Equal: (e, source) ->
    new Nodes.Equals(@visit(e.left, source), @visit(e.right, source))

  visit_Expressions_Column: (e, source) ->
    new Nodes.Column(source, e.table.resourceName(), e.resourceName())

