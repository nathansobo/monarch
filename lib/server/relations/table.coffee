{ reopen } = require("../core").Util
InsertBuilder = require "../sql/insert_builder"
UpdateBuilder = require "../sql/update_builder"
Connection = require "../db/connection"

module.exports = (Table) ->

  reopen Table, ->
    toUpdateSql: (args...) ->
      (new UpdateBuilder).visit(this, args...).toSql()

    toInsertSql: (args...) ->
      (new InsertBuilder).visit(this, args...).toSql()

    create: (args..., f) ->
      Connection.query(@toInsertSql(args...), f)

