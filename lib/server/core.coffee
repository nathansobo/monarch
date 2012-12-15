_ = require 'underscore'
Snockets = require 'snockets'
snockets = new Snockets

core = "#{__dirname}/../core"
snockets.scan "#{core}/index.coffee", async: false
paths = snockets.depGraph.getChain("#{core}/index.coffee")

window = {}
initJs = snockets.getConcatenation paths[0], async: false
eval(initJs)

Monarch = window.Monarch
for path in paths[1..]
  js = snockets.getConcatenation path, async: false
  eval(js)

module.exports = Monarch
