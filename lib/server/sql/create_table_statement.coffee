module.exports = ({ Monarch, _ }) ->

  { underscore } = Monarch.Util.Inflection

  class Monarch.Sql.CreateTableStatement
    constructor: (@tableName, @columnDefinitions) ->

    toSql: (tableName, done) ->
      "CREATE TABLE #{@tableName} (#{@columnClause()});"

    columnClause: ->
      expressions = for name, type of @columnDefinitions
        "#{underscore(name)} #{@databaseType(type)}"
      expressions.join(', ')

    databaseType: (type) ->
      Monarch.Sql.Types[type] || throw new Error("Unknown column type '#{type}'")
