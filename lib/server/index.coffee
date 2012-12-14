_ = require 'underscore'
Monarch = require './load_core'

loader = require './util/global_loader'
loader.configure(
  dir: __dirname,
  globals: { Monarch, _ }
)

_.extend Monarch,
  Sql: {}
  resourceUrlSeparator: '_'

loader.require('./sql/literal')
loader.require('./sql/binary')
loader.requireTree('.')

module.exports = Monarch
