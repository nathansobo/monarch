{ Base } = require("../../core")

class Binary extends Base
  constructor: (@left, @right) ->

  toSql: ->
    [
      operandSql(this, @left)
      @operator,
      operandSql(this, @right)
    ].join(' ')

operandSql = (node, operand) ->
  if node.operandNeedsParens?(operand)
    ["(", operand.toSql(), ")"].join(' ')
  else
    operand.toSql()

module.exports = Binary
