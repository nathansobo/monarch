Binary = require "./binary"

module.exports = class Union extends Binary
  source: -> @left.source()
  columns: -> @left.columns()

  operator: 'UNION'
  operandNeedsParens: -> true

