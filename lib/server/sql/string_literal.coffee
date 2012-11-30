module.exports = ({ Monarch, _ }) ->

  class Monarch.Sql.StringLiteral extends Monarch.Sql.Literal
    toSql: ->
      "'" + super + "'"
