_ = require "underscore"
{ Base } = require "../../core"

class Update extends Base
  constructor: (table, assignments) ->
    @setTable(table)
    @setAssignments(assignments)

  @accessors 'table', 'assignments', 'condition'

  toSql: ->
    _.compact([
      "UPDATE",
      @table().toSql(),
      "SET",
      @assignmentsClauseSql(),
      @whereClauseSql()
    ]).join(' ')

  assignmentsClauseSql: ->
    (assignment.toSql() for assignment in @assignments()).join(', ')

  whereClauseSql: ->
    "WHERE " + @condition().toSql() if @condition()

module.exports = Update
