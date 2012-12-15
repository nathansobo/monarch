TupleBuilder = require "./tuple_builder"
Connection = require "./connection"

module.exports =
  all: (r, f) ->
    Connection.query(r.toSql(), (err, result) ->
      return f(err, null) if err
      records = TupleBuilder.visit(r, result.rows)
      f(null, records))

