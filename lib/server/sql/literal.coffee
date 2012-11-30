module.exports = ({ Monarch, _ }) ->

  class Monarch.Sql.Literal
    constructor: (@value) ->

    toSql: ->
      @value.toString()
