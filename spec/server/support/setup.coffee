pg = require 'pg'
_ = require 'underscore'
async = require 'async'
testConfig = require './database'

adminConfig = _.extend({}, testConfig, database: 'postgres')
testDatabase = testConfig.database

pg.connect adminConfig, (err, client) ->
  checkError(err)

  async.series([
    (f) -> client.query("DROP DATABASE IF EXISTS #{testDatabase};", f)
    (f) -> client.query("CREATE DATABASE #{testDatabase};", f)
  ], (err) ->
    checkError(err)
    console.log "Test database successfully set up."
    pg.end()
  )

checkError = (err) -> throw new Error(err) if err
