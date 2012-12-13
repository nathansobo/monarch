module.exports = ({ Monarch, _ }) ->

  Monarch.Db.RecordRetriever =
    all: (r, f) ->
      Monarch.Db.query(r.toSql(), (err, result) ->
        return f(err, null) if err
        records = (Monarch.Db.TupleBuilder.visit(r, row) for row in result.rows)
        f(null, records))
