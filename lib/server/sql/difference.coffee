module.exports = ({ Monarch, _ }) ->

  class Monarch.Sql.Difference
    constructor: (@left, @right) ->

    toSql: ->
      [
        "(", @left.toSql(), ")",
        "EXCEPT",
        "(", @right.toSql(), ")"
      ].join(' ')
