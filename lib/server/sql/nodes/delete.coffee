_ = require "underscore"
{ Base } = require "../../core"

module.exports = class Delete extends Base
  constructor: (table, assignments) ->
    @setTable(table)

  @accessors 'table', 'condition'

  toSql: ->
    _.compact([
      "DELETE FROM",
      @table().toSql(),
      @whereClauseSql()
    ]).join(' ')

  whereClauseSql: ->
    "WHERE " + @condition().toSql() if @condition()

