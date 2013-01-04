_ = require "underscore"
Monarch = require './core'
connection = require './default_connection_pool'

_.extend Monarch,
  resourceUrlSeparator: '_'
  ConnectionPool: require "./connection_pool"
  Schema: require "./schema"

  configureConnection: (args...) ->
    connection.configure(args...)

require('./relations/relation')(Monarch.Relations.Relation)
require('./relations/table')(Monarch.Relations.Table)
require('./relations/selection')(Monarch.Relations.Selection)
require('./record')(Monarch.Record)

module.exports = Monarch
