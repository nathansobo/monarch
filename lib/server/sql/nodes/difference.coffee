Binary = require "./binary"

module.exports = class Difference extends Binary
  @delegate 'table', 'columns', to: 'left'
  operator: 'EXCEPT'
  operandNeedsParens: -> true

