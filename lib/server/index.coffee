_ = require "underscore"
Monarch = require './core'

_.extend Monarch,
  resourceUrlSeparator: '_'
  Connection: require "./connection"
  Schema: require "./schema"

require('./relations/relation')(Monarch.Relations.Relation)
require('./relations/table')(Monarch.Relations.Table)
require('./relations/selection')(Monarch.Relations.Selection)
require('./record')(Monarch.Record)

module.exports = Monarch
