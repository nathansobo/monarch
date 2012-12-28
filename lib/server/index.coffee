Monarch = require './core'
Monarch.Db = require "./db"
Monarch.resourceUrlSeparator = '_'
require('./relations/relation')(Monarch.Relations.Relation)
require('./relations/table')(Monarch.Relations.Table)
require('./relations/selection')(Monarch.Relations.Selection)
module.exports = Monarch
