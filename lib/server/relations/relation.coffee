module.exports = ({ Monarch, _ }) ->

  _.extend Monarch.Relations.Relation.prototype,
    toSql: ->
      (new Monarch.Sql.Builder).visit(this).toSql()

    all: (f) ->
      Monarch.Db.RecordRetriever.all(this, f)
