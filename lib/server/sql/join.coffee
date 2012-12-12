module.exports = ({ Monarch, _ }) ->

  class Monarch.Sql.Join
    constructor: (@left, @right, @condition) ->

    resolveColumnName: (args...) ->
      @left.resolveColumnName(args...) || @right.resolveColumnName(args...)

    toSql: ->
      [
        @left.toSql(),
        "INNER JOIN",
        @rightSql(),
        "ON",
        @condition.toSql()
      ].join(' ')

    rightSql: ->
      if @right instanceof Monarch.Sql.Join
        "( #{@right.toSql()} )"
      else
        @right.toSql()
