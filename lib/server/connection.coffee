_ = require "underscore"
pg = require 'pg'

REQUIRED_KEYS = ['host', 'port', 'user', 'database']
OPTIONAL_KEYS = ['password']
CONFIG_KEYS = REQUIRED_KEYS.concat(OPTIONAL_KEYS)

module.exports =
  configure: (params) ->
    for key, value of params
      config[key] = params[key] if _.include(REQUIRED_KEYS, key)

  query: (sql, callback) ->
    return callback(error) if error = configError()
    pg.connect config, (err, client) ->
      return callback(err) if err
      client.query(sql, callback)

config = {}

configError = ->
  missingConfigOptions = _.filter REQUIRED_KEYS, (key) -> !config[key]
  unless _.isEmpty(missingConfigOptions)
    new Error("Missing connection parameters: " + missingConfigOptions.join(', '))

