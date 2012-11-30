module.exports = ({ Monarch, _ }) ->

  class Monarch.Sql.BinaryOperator
    constructor: (@left, @right, @operator) ->

    toSql: ->
      [
        @left.toSql(),
        @operator,
        @right.toSql()
      ].join(' ')
