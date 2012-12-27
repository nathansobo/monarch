Monarch = require './core'
Monarch.Db = require "./db"
Monarch.resourceUrlSeparator = '_'
require('./relations/relation')(Monarch.Relations.Relation)
require('./relations/table')(Monarch.Relations.Table)
module.exports = Monarch
