module.exports = class Update
  constructor: (@table, @assignments) ->

  toSql: ->
    [
      "UPDATE",
      @table.toSql(),
      "SET",
      @assignmentsClauseSql()
    ].join(' ')

  assignmentsClauseSql: ->
    (assignment.toSql() for assignment in @assignments).join(', ')
