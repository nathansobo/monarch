{ Monarch } = require "../spec_helper"

describe "DeleteBuilder", ->
  class Blog extends Monarch.Record
    @extended(this)
    @columns
      public: 'boolean'
      title: 'string'
      authorId: 'integer'

  blogs = Blog.table

  describe "tables", ->
    it "constructs a delete statement", ->
      sql = blogs.deleteSql()
      expect(sql).toBeLikeQuery("""
        DELETE FROM "blogs"
      """)

  describe "selections", ->
    it "constructs a delete statement with a condition", ->
      sql = blogs.where(authorId: 5).deleteSql()
      expect(sql).toBeLikeQuery("""
        DELETE FROM
          "blogs"
        WHERE
          "blogs"."author_id" = 5
      """)

