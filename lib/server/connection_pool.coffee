_ = require "underscore"
pg = require('pg').native

REQUIRED_KEYS = ['host', 'port', 'user', 'database']
OPTIONAL_KEYS = ['password']
CONFIG_KEYS = REQUIRED_KEYS.concat(OPTIONAL_KEYS)

class ConnectionPool
  constructor: ->
    @_config = {}

  configure: (params) ->
    for key, value of params
      @_config[key] = params[key] if _.include(REQUIRED_KEYS, key)

  query: (sql, callback) ->
    return callback(error) if error = configError(this)
    pg.connect @_config, (err, client) ->
      return callback(err) if err
      client.query(sql, callback)

configError = (pool) ->
  missingConfigOptions = _.filter REQUIRED_KEYS, (key) -> !pool._config[key]
  unless _.isEmpty(missingConfigOptions)
    new Error("Missing connection parameters: " + missingConfigOptions.join(', '))

module.exports = ConnectionPool
