module.exports = ({ Monarch, _ }) ->

  class Monarch.Sql.Join
    constructor: (@left, @right, @condition) ->

    resolveColumnName: (args...) ->
      @left.resolveColumnName(args...) || @right.resolveColumnName(args...)

    operator: "INNER JOIN",

    toSql: ->
      [
        Monarch.Sql.Binary.toSql.call(this),
        "ON",
        @condition.toSql()
      ].join(' ')

    operandNeedsParens: (operand) ->
      (operand is @right) and (operand instanceof Monarch.Sql.Join)
