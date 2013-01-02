InsertBuilder = require "../sql/insert_builder"
UpdateBuilder = require "../sql/update_builder"
DeleteBuilder = require "../sql/delete_builder"
Connection = require "../connection"

module.exports = (Table) ->

  Table.reopen ->
    createSql: -> buildSql(this, InsertBuilder, arguments)
    updateSql: -> buildSql(this, UpdateBuilder, arguments)
    deleteSql: -> buildSql(this, DeleteBuilder, arguments)

    create: (args..., f) -> executeAndGetRowCount(@createSql(args...), f)
    updateAll: (args..., f) -> executeAndGetRowCount(@updateSql(args...), f)
    deleteAll: (args..., f) -> executeAndGetRowCount(@deleteSql(args...), f)

buildSql = (relation, builderClass, args) ->
  (new builderClass).buildQuery(relation, args...).toSql()

executeAndGetRowCount = (sql, f) ->
  Connection.query sql, (err, result) ->
    return f(err) if err
    f(null, result.rowCount)
