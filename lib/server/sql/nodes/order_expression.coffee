class OrderExpression
  constructor: (@column, @directionString) ->

  toSql: ->
    "#{@column.toSql()} #{@directionString}"

module.exports = OrderExpression
