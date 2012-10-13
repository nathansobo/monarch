task "build", "compile source files", ->
  fs = require("fs")
  Snockets = require 'snockets'
  snockets = new Snockets

  fs.writeFileSync(
    "monarch.js",
    snockets.getConcatenation 'lib/monarch/index.coffee', async: false)

  fs.writeFileSync(
    "monarch_test_support.js",
    snockets.getConcatenation 'lib/monarch_test_support/index.coffee', async: false)


task "spec", "run tests", ->
  require __dirname + "/spec/runner/server"
  console.log "Spec server listening on port 8888"
