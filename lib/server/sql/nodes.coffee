files = [
  "and"
  "assignment"
  "column"
  "delete"
  "difference"
  "equals"
  "insert"
  "insert_column"
  "join"
  "literal"
  "null"
  "order_expression"
  "select"
  "string_literal"
  "subquery"
  "table"
  "union"
  "update"
]

{ camelize, capitalize } = require("../core").Util.Inflection
for file in files
  klass = require "./nodes/#{file}"
  klassName = capitalize(camelize(file))
  module.exports[klassName] = klass

