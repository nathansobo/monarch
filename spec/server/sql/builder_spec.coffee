{ Monarch } = require "../spec_helper"

describe "Sql.Builder", ->
  blogs = blogPosts = null

  class Blog extends Monarch.Record
    @extended(this)
    @columns
      public: 'boolean'
      title: 'string'
      authorId: 'integer'

  class BlogPost extends Monarch.Record
    @extended(this)
    @columns
      public: 'boolean'
      blogId: 'integer'
      title: 'string'

  beforeEach ->
    blogs = Blog.table
    blogPosts = BlogPost.table

  describe "tables", ->
    it "constructs a table query", ->
      expect(blogPosts.toSql()).toBeLikeQuery("""
        SELECT * FROM "blog_posts"
      """)

  describe "selections", ->
    it "constructs a query with the right WHERE clause", ->
      relation = blogPosts.where({ public: true, blogId: 1 })
      expect(relation.toSql()).toBeLikeQuery("""
        SELECT * FROM "blog_posts"
        WHERE "blog_posts"."public" = true AND "blog_posts"."blog_id" = 1
      """)

    it "quotes string literals correctly", ->
      relation = blogPosts.where({ title: "Node Fibers and You" })
      expect(relation.toSql()).toBeLikeQuery("""
        SELECT * FROM "blog_posts"
        WHERE "blog_posts"."title" = 'Node Fibers and You'
      """)

  describe "orderings", ->
    it "constructs a query with a valid order by clause", ->
      relation = blogPosts.orderBy("title desc")
      expect(relation.toSql()).toBeLikeQuery("""
        SELECT * FROM "blog_posts"
        ORDER BY "blog_posts"."title" DESC, "blog_posts"."id" ASC
      """)

  describe "limits", ->
    it "constructs a limit query", ->
      relation = blogPosts.limit(5)
      expect(relation.toSql()).toBeLikeQuery("""
        SELECT * FROM "blog_posts" LIMIT 5
      """)

    it "constructs a limit query with an offset", ->
      relation = blogPosts.limit(5, 2)
      expect(relation.toSql()).toBeLikeQuery("""
        SELECT * FROM "blog_posts" LIMIT 5 OFFSET 2
      """)

  describe "unions", ->
    it "constructs a set union query", ->
      left = blogPosts.where(blogId: 5)
      right = blogPosts.where(public: true)
      relation = left.union(right)
      expect(relation.toSql()).toBeLikeQuery("""
        SELECT * FROM "blog_posts" WHERE "blog_posts"."blog_id" = 5
        UNION
        SELECT * FROM "blog_posts" WHERE "blog_posts"."public" = true
      """)

  describe "differences", ->
    it "constructs a set difference query", ->
      left = blogPosts.where(blogId: 5)
      right = blogPosts.where(public: true)
      relation = left.difference(right)
      expect(relation.toSql()).toBeLikeQuery("""
        SELECT * FROM "blog_posts" WHERE "blog_posts"."blog_id" = 5
        EXCEPT
        SELECT * FROM "blog_posts" WHERE "blog_posts"."public" = true
      """)

  describe "joins", ->
    it "constructs a join query", ->
      relation = blogs.join(blogPosts)
      expect(relation.toSql()).toBeLikeQuery("""
        SELECT * FROM "blogs"
        INNER JOIN "blog_posts"
        ON "blogs"."id" = "blog_posts"."blog_id"
      """)
