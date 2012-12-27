Nodes = require "./nodes"
Visitor = require("../core").Util.Visitor

module.exports = class QueryBuilder
  visit: Visitor.visit

  visit_String: (e) ->
    new Nodes.StringLiteral(e)

  visit_Boolean: (e) ->
    new Nodes.Literal(e)

  visit_Number: (e) ->
    new Nodes.Literal(e)
