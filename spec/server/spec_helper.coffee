_ = require 'underscore'

beforeEach ->
  @addMatchers
    toBeLikeQuery: (sql) ->
      normalizeSql(@actual) == normalizeSql(sql)

normalizeSql = (string) ->
  string
    .replace(/\s+/g, ' ')
    .replace(/[(\s*$)]/g, '')

databaseConfig = require "./support/database"
Monarch = require "#{__dirname}/../../lib/server/index"
Monarch.Db.configure(databaseConfig)

module.exports =
  Monarch: Monarch
  _: _
  async: require 'async'
  pg: require 'pg'
