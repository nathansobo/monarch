Binary = require "./binary"

class Union extends Binary
  @delegate 'table', 'columns', to: 'left'
  operator: 'UNION'
  operandNeedsParens: -> true

module.exports = Union
