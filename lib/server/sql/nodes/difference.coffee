Binary = require "./binary"

class Difference extends Binary
  @delegate 'table', 'columns', to: 'left'
  operator: 'EXCEPT'
  operandNeedsParens: -> true

module.exports = Difference
