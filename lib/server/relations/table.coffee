{ reopen } = require("../core").Util
InsertBuilder = require "../sql/insert_builder"
UpdateBuilder = require "../sql/update_builder"
DeleteBuilder = require "../sql/delete_builder"
Connection = require "../db/connection"

module.exports = (Table) ->

  reopen Table, ->
    updateSql: (args...) ->
      (new UpdateBuilder).buildQuery(this, args...).toSql()

    createSql: (args...) ->
      (new InsertBuilder).buildQuery(this, args...).toSql()

    deleteSql: (args...) ->
      (new DeleteBuilder).buildQuery(this, args...).toSql()

    create: (args..., f) ->
      executeAndGetRowCount(@createSql(args...), f)

    updateAll: (args..., f) ->
      executeAndGetRowCount(@updateSql(args...), f)

    deleteAll: (args..., f) ->
      executeAndGetRowCount(@deleteSql(args...), f)

executeAndGetRowCount = (sql, f) ->
  Connection.query sql, (err, result) ->
    return f(err) if err
    f(null, result.rowCount)
