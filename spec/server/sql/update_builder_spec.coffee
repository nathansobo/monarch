{ Monarch } = require "../spec_helper"

describe "UpdateBuilder", ->
  class Blog extends Monarch.Record
    @extended(this)
    @columns
      public: 'boolean'
      title: 'string'
      authorId: 'integer'

  blogs = Blog.table

  describe "tables", ->
    it "constructs an update statement", ->
      sql = blogs.updateSql(public: false, title: "Updated Blog")
      expect(sql).toBeLikeQuery("""
        UPDATE "blogs"
        SET
          "public" = false,
          "title" = 'Updated Blog'
      """)

  describe "selections", ->
    it "constructs an update statement with a condition", ->
      sql = blogs.where(authorId: 5).updateSql(
        public: false,
        title: "Updated Blog"
      )
      expect(sql).toBeLikeQuery("""
        UPDATE "blogs"
        SET
          "public" = false,
          "title" = 'Updated Blog'
        WHERE
          "blogs"."author_id" = 5
      """)
