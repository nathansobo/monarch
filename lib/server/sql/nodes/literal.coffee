class Literal
  constructor: (@value) ->

  toSql: ->
    @value.toString()

module.exports = Literal
