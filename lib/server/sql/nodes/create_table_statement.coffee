{ underscore } = require("../../core").Util.Inflection
Types = require "./types"

class CreateTableStatement
  constructor: (@tableName, @columnDefinitions) ->

  toSql: (tableName, done) ->
    "CREATE TABLE #{@tableName} (#{@columnClause()});"

  columnClause: ->
    expressions = for name, type of @columnDefinitions
      "#{underscore(name)} #{@databaseType(type)}"
    expressions.join(', ')

  databaseType: (type) ->
    Types[type] || throw new Error("Unknown column type '#{type}'")

module.exports = CreateTableStatement
