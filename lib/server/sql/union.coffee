module.exports = ({ Monarch, _ }) ->

  class Monarch.Sql.Union extends Monarch.Base
    constructor: (@left, @right) ->

    @delegate 'source', 'columns', to: 'left'

    canHaveJoinAdded: -> false

    toSql: ->
      [
        "(", @left.toSql(), ")",
        "UNION",
        "(", @right.toSql(), ")"
      ].join(' ')
