module.exports = ({ Monarch, _ }) ->

  class Monarch.Sql.JoinTableRef
    constructor: (@left, @right, @condition) ->

    resolveColumnName: (args...) ->
      @left.resolveColumnName(args...) || @right.resolveColumnName(args...)

    toSql: ->
      [
        @left.toSql(),
        "INNER JOIN",
        @right.toSql(),
        "ON",
        @condition.toSql()
      ].join(' ')
