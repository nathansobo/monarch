beforeEach ->
  @addMatchers
    toBeLikeQuery: (sql) ->
      normalizeSql(@actual) == normalizeSql(sql)

normalizeSql = (string) ->
  string
    .replace(/\s+/g, ' ')
    .replace(/[(\s*$)]/g, '')

module.exports =
  Monarch: require "#{__dirname}/../../lib/server/index"
  _: require "underscore"
