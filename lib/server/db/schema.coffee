module.exports = ({ Monarch, _ }) ->

  Monarch.Db.Schema = 
    dropTable: (tableName, done) ->
      sql = "DROP TABLE IF EXISTS #{tableName};"
      Monarch.Db.query(sql, done)

    createTable: (tableName, columnDefinitions, done) ->
      statement = new Monarch.Sql.CreateTableStatement(tableName, columnDefinitions)
      Monarch.Db.query(statement.toSql(), done)
