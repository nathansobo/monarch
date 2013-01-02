{ Monarch, async, pg, _ } = require "./spec_helper"

describe "Schema", ->
  { Schema, Connection } = Monarch

  describe ".createTable", ->
    beforeEach (done) ->
      async.series [
        (f) -> Schema.dropTable('things', f),
        (f) -> Schema.createTable('things', {
          id: 'integer',
          title: 'string',
          public: 'boolean',
          createdAt: 'datetime'
        }, f)
      ], done

    it "creates a table", (done) ->
      Connection.query 'SELECT * from things', (err, results) ->
        expect(results.rowCount).toBe(0)
        done()

    it "converts the column names to underscore-style", (done) ->
      sql = "INSERT INTO things (created_at) VALUES ('2012-08-21');"
      Connection.query sql, (err, results) ->
        expect(results.rowCount).toBe(1)
        done()

    it "gives the columns the correct types", (done) ->
      sql = """
        SELECT column_name, data_type FROM information_schema.columns
        WHERE table_name = 'things';
      """

      Connection.query sql, (err, results) ->
        rows = _.sortBy(results.rows, (row) -> row.column_name)
        expect(rows).toEqual([
          { column_name: "created_at", data_type: "timestamp without time zone" }
          { column_name: "id", data_type: "integer" }
          { column_name: "public", data_type: "boolean" }
          { column_name: "title", data_type: "character varying" }
        ])
        done()
