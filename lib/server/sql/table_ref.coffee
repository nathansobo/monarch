module.exports = ({ Monarch, _ }) ->

  class Monarch.Sql.TableRef
    constructor: (@tableName) ->

    toSql: ->
      '"' + @tableName + '"'
