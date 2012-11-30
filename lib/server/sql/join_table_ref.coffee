module.exports = ({ Monarch, _ }) ->

  class Monarch.Sql.JoinTableRef
    constructor: (@left, @right, @condition) ->

    toSql: ->
      [
        @left.toSql(),
        "INNER JOIN",
        @right.toSql(),
        "ON",
        @condition.toSql()
      ].join(' ')
