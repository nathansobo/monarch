class InsertColumn
  constructor: (@name) ->

  toSql: ->
    '"' + @name + '"'

module.exports = InsertColumn
