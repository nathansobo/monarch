_ = require 'underscore'
Monarch = require './load_core'

loader = require './util/global_loader'
loader.configure(
  dir: __dirname,
  globals: { Monarch, _ }
)

Monarch.Sql = {}

loader.requireTree('.')

module.exports = Monarch
