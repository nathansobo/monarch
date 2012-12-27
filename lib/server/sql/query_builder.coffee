Nodes = require "./nodes"
Visitor = require("../core").Util.Visitor

visitPrimitive = (nodeClass) ->
  (value) -> new nodeClass(value)

module.exports = class QueryBuilder
  visit: Visitor.visit

  visit_Boolean: visitPrimitive(Nodes.Literal)
  visit_Number: visitPrimitive(Nodes.Literal)
  visit_String: visitPrimitive(Nodes.StringLiteral)
  visit_null: visitPrimitive(Nodes.Null)
