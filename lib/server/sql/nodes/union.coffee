Binary = require "./binary"

module.exports = class Union extends Binary
  @delegate 'table', 'columns', to: 'left'
  operator: 'UNION'
  operandNeedsParens: -> true

