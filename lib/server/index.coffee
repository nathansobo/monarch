Monarch = require './core'
Monarch.Db = require "./db"
Monarch.resourceUrlSeparator = '_'
require('./relations/relation')(Monarch.Relations.Relation)
module.exports = Monarch
