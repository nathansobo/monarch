Literal = require "./literal"

module.exports = class StringLiteral extends Literal
  toSql: ->
    "'" + super + "'"
