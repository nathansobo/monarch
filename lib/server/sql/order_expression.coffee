module.exports = ({ Monarch, _ }) ->

  class Monarch.Sql.OrderExpression
    constructor: (@column, @directionString) ->

    toSql: ->
      "#{@column.toSql()} #{@directionString}"
