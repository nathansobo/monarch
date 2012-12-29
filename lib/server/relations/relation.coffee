_ = require "underscore"
SelectBuilder = require "../sql/select_builder"
TupleBuilder = require "../db/tuple_builder"
Connection = require "../db/connection"

module.exports = (Relation) ->

  Relation.reopen ->
    readSql: ->
      (new SelectBuilder).buildQuery(this).toSql()

    all: (f) ->
      self = this
      Connection.query @readSql(), (err, result) ->
        return f(err) if err
        f(null, TupleBuilder.visit(self, result.rows))

    at: (index, f) ->
      @offset(index).first(f)

    find: (predicate, f) ->
      predicate = { id: predicate } unless _.isObject(predicate)
      @where(predicate).first(f)

    first: (f) ->
      @limit(1).all (err, results) ->
        f(err, results?[0])

