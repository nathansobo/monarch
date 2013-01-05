Binary = require "./binary"

class Join extends Binary
  constructor: (@left, @right, @condition) ->

  resolveColumnName: (args...) ->
    @left.resolveColumnName(args...) || @right.resolveColumnName(args...)

  operator: "INNER JOIN",

  toSql: ->
    [
      super,
      "ON",
      @condition.toSql()
    ].join(' ')

  operandNeedsParens: (operand) ->
    (operand is @right) and (operand instanceof Join)

module.exports = Join
