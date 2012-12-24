files = [
  "select"
  "table"
  "join"
  "union"
  "difference"
  "column"
  "and"
  "equals"
  "literal"
  "string_literal"
  "subquery"
  "order_expression"
  "insert"
  "insert_column"
]

{ camelize, capitalize } = require("../core").Util.Inflection
for file in files
  klass = require "./nodes/#{file}"
  klassName = capitalize(camelize(file))
  module.exports[klassName] = klass

