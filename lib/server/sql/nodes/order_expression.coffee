module.exports = class OrderExpression
  constructor: (@column, @directionString) ->

  toSql: ->
    "#{@column.toSql()} #{@directionString}"
