module.exports = ({ Monarch, _ }) ->

  class Monarch.Sql.OrderByExpression
    constructor: (@tableName, @columnName, @directionString) ->

    toSql: ->
      """
        "#{@tableName}"."#{@columnName}" #{@directionString}
      """
