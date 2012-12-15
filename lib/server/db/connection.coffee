pg = require 'pg'

module.exports =
  config: {}

  configure: (params) ->
    for key in ['host', 'port', 'user',  'password', 'database']
      @config[key] = params[key] if params[key]

  query: (sql, callback) ->
    pg.connect @config, (err, client) ->
      client.query(sql, callback)

