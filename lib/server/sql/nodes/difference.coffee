Binary = require "./binary"

module.exports = class Difference extends Binary
  source: -> @left.source()
  columns: -> @left.columns()

  operator: 'EXCEPT'
  operandNeedsParens: -> true

