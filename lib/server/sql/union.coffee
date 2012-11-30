module.exports = ({ Monarch, _ }) ->

  class Monarch.Sql.Union
    constructor: (@left, @right) ->

    toSql: ->
      [@left.toSql(), "UNION", @right.toSql()].join(' ')
