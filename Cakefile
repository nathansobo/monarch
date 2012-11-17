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
  module = require('watch-tree')
  paths = ["spec/server", "lib/core", "lib/server"]
  for path in paths
    fullPath = __dirname + '/' + path
    module.watchTree(fullPath, 'sample-rate': 10)
      .on('fileModified', runTests)
      .on('fileCreated', runTests)
      .on('fileDeleted', runTests)
  runTests()

task "spec:setup", "setup database for server-side tests", ->
  require './spec/server/support/setup'

runTests = ->
  { spawn } = require 'child_process'
  bin = "#{__dirname}/node_modules/jasmine-node/bin/jasmine-node"
  proc = spawn(bin, [ "--coffee", "#{__dirname}/spec/server" ])
  proc.stdout.pipe(process.stdout)
  proc.stderr.pipe(process.stderr)
