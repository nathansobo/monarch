{ Monarch } = require "../spec_helper"

describe "InsertBuilder", ->
  class Blog extends Monarch.Record
    @extended(this)
    @columns
      public: 'boolean'
      title: 'string'
      authorId: 'integer'

  blogs = Blog.table

  describe "when passed a single hash of attributes", ->
    it "creates an insert statement with a single list of values", ->
      sql = blogs.toInsertSql(public: true, title: 'Blog1', authorId: 5)
      expect(sql).toBeLikeQuery("""
        INSERT INTO "blogs"
          ("public", "title", "author_id")
        VALUES
          (true, 'Blog1', 5)
      """)
