CreateTableStatement = require "./sql/nodes/create_table_statement"
connection = require "./default_connection_pool"

module.exports =
  dropTable: (tableName, done) ->
    sql = "DROP TABLE IF EXISTS #{tableName};"
    connection.query(sql, done)

  createTable: (tableName, columnDefinitions, done) ->
    statement = new CreateTableStatement(tableName, columnDefinitions)
    connection.query(statement.toSql(), done)

  connection: ->
    connection
