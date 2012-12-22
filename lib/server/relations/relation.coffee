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

    at: (index, f) ->
      @offset(index).first(f)

    find: (predicate, f) ->
      predicate = { id: predicate } unless _.isObject(predicate)
      @where(predicate).first(f)

    first: (f) ->
      @limit(1).all (err, results) ->
        f(err, results?[0])

