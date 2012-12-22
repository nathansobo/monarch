_ = require "underscore"
SqlBuilder = require "../sql/builder"
TupleBuilder = require "../db/tuple_builder"
Connection = require "../db/connection"

module.exports = (Relation) ->

  _.extend Relation.prototype,
    toSql: ->
      (new SqlBuilder).visit(this).toSql()

    all: (f) ->
      self = this
      Connection.query @toSql(), (err, result) ->
        return f(err) if err
        f(null, TupleBuilder.visit(self, result.rows))

