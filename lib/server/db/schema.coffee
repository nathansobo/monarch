CreateTableStatement = require "../sql/nodes/create_table_statement"
Connection = require "./connection"

module.exports =
  dropTable: (tableName, done) ->
    sql = "DROP TABLE IF EXISTS #{tableName};"
    Connection.query(sql, done)

  createTable: (tableName, columnDefinitions, done) ->
    statement = new CreateTableStatement(tableName, columnDefinitions)
    Connection.query(statement.toSql(), done)

