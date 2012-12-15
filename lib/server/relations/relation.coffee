_ = require "underscore"
SqlBuilder = require "../sql/builder"
RecordRetriever = require "../db/record_retriever"

module.exports = (Relation) ->

  _.extend Relation.prototype,
    toSql: ->
      (new SqlBuilder).visit(this).toSql()

    all: (f) ->
      RecordRetriever.all(this, f)

