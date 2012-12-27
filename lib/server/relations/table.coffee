{ reopen } = require("../core").Util
InsertBuilder = require "../sql/insert_builder"
Connection = require "../db/connection"

module.exports = (Table) ->

  reopen Table, ->
    toInsertSql: (args...) ->
      (new InsertBuilder).visit(this, args...).toSql()

    create: (args..., f) ->
      Connection.query(@toInsertSql(args...), f)

