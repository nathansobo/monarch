module.exports = ({ Monarch, _ }) ->

  class Monarch.Sql.Column
    constructor: (@tableName, @name) ->

    toSql: ->
      "\"#{@tableName}\".\"#{@name}\""

    toSelectClauseSql: ->
      @toSql() + " as " + @qualifiedName()

    qualifiedName: ->
      "#{@tableName}__#{@name}"
