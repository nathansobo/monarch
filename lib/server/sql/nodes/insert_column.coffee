module.exports = class InsertColumn
  constructor: (@name) ->

  toSql: ->
    '"' + @name + '"'

