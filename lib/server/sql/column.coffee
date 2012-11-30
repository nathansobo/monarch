module.exports = ({ Monarch, _ }) ->

  class Monarch.Sql.Column
    constructor: (@tableName, @name) ->

    toSql: ->
      """ "#{@tableName}"."#{@name}" """
