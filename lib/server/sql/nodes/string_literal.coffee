Literal = require "./literal"

class StringLiteral extends Literal
  toSql: ->
    "'" + super + "'"

module.exports = StringLiteral
