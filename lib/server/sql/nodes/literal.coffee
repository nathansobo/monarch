module.exports = class Literal
  constructor: (@value) ->

  toSql: ->
    @value.toString()
