{ Monarch } = require "../spec_helper"

describe "UpdateBuilder", ->
  class Blog extends Monarch.Record
    @extended(this)
    @columns
      public: 'boolean'
      title: 'string'
      authorId: 'integer'

  blogs = Blog.table

  it "constructs an update statement", ->
    sql = blogs.updateSql(public: false, title: "Updated Blog")
    expect(sql).toBeLikeQuery("""
      UPDATE "blogs"
      SET
        "public" = false,
        "title" = 'Updated Blog'
    """)

