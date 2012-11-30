task "build", "compile source files", ->
  fs = require("fs")
  Snockets = require 'snockets'
  snockets = new Snockets

  fs.writeFileSync(
    "monarch.js",
    snockets.getConcatenation 'lib/client/index.coffee', async: false)

  fs.writeFileSync(
    "monarch_test_support.js",
    snockets.getConcatenation 'lib/client_test_support/index.coffee', async: false)

task "spec:client", "start server for client-side tests", ->
  require "#{__dirname}/script/server"
  console.log "Spec server listening on port 8888"

task "spec:server", "run server-side tests", ->
  { spawn } = require 'child_process'
  bin = "#{__dirname}/node_modules/jasmine-node/bin/jasmine-node"
  specDir = "#{__dirname}/spec/server"
  proc = spawn(bin, [ "--coffee", specDir ])
  proc.stdout.pipe(process.stdout)
  proc.stderr.pipe(process.stderr)
