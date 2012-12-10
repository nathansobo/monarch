{ Monarch } = require "../spec_helper"

describe "Sql.Builder", ->
  blogs = blogPosts = comments = null

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
      title: 'string'
      blogId: 'integer'

  beforeEach ->
    blogs = Blog.table
    blogPosts = BlogPost.table

  describe "tables", ->
    it "constructs a table query", ->
      expect(blogPosts.toSql()).toBeLikeQuery("""
        SELECT
          "blog_posts"."id" as blog_posts__id,
          "blog_posts"."public" as blog_posts__public,
          "blog_posts"."title" as blog_posts__title,
          "blog_posts"."blog_id" as blog_posts__blog_id
        FROM
          "blog_posts"
      """)

  describe "selections", ->
    it "constructs a query with the right WHERE clause", ->
      relation = blogPosts.where({ public: true, blogId: 1 })
      expect(relation.toSql()).toBeLikeQuery("""
        SELECT
          "blog_posts"."id" as blog_posts__id,
          "blog_posts"."public" as blog_posts__public,
          "blog_posts"."title" as blog_posts__title,
          "blog_posts"."blog_id" as blog_posts__blog_id
        FROM
          "blog_posts"
        WHERE
          "blog_posts"."public" = true
          AND "blog_posts"."blog_id" = 1
      """)

    it "quotes string literals correctly", ->
      relation = blogPosts.where({ title: "Node Fibers and You" })
      expect(relation.toSql()).toBeLikeQuery("""
        SELECT
          "blog_posts"."id" as blog_posts__id,
          "blog_posts"."public" as blog_posts__public,
          "blog_posts"."title" as blog_posts__title,
          "blog_posts"."blog_id" as blog_posts__blog_id
        FROM
          "blog_posts"
        WHERE
          "blog_posts"."title" = 'Node Fibers and You'
      """)

  describe "orderings", ->
    describe "an ordering on a table", ->
      it "adds the correct order by clause", ->
        relation = blogPosts.orderBy("title desc")
        expect(relation.toSql()).toBeLikeQuery("""
          SELECT
            "blog_posts"."id" as blog_posts__id,
            "blog_posts"."public" as blog_posts__public,
            "blog_posts"."title" as blog_posts__title,
            "blog_posts"."blog_id" as blog_posts__blog_id
          FROM
            "blog_posts"
          ORDER BY
            "blog_posts"."title" DESC,
            "blog_posts"."id" ASC
        """)

    describe "an ordering on a limit", ->
      it "adds the correct order by clause", ->
        relation = blogPosts.limit(2).orderBy("title desc")
        expect(relation.toSql()).toBeLikeQuery("""
          SELECT
            "t1"."blog_posts__id",
            "t1"."blog_posts__public",
            "t1"."blog_posts__title",
            "t1"."blog_posts__blog_id"
          FROM
            (
              SELECT
                "blog_posts"."id" as blog_posts__id,
                "blog_posts"."public" as blog_posts__public,
                "blog_posts"."title" as blog_posts__title,
                "blog_posts"."blog_id" as blog_posts__blog_id
              FROM
                "blog_posts"
              LIMIT
                2
            ) as "t1"
          ORDER BY
            "t1"."blog_posts__title" DESC,
            "t1"."blog_posts__id" ASC
        """)

  describe "limits", ->
    it "constructs a limit query", ->
      relation = blogPosts.limit(5)
      expect(relation.toSql()).toBeLikeQuery("""
        SELECT
          "blog_posts"."id" as blog_posts__id,
          "blog_posts"."public" as blog_posts__public,
          "blog_posts"."title" as blog_posts__title,
          "blog_posts"."blog_id" as blog_posts__blog_id
        FROM
          "blog_posts"
        LIMIT
          5
      """)

    it "constructs a limit query with an offset", ->
      relation = blogPosts.limit(5, 2)
      expect(relation.toSql()).toBeLikeQuery("""
        SELECT
          "blog_posts"."id" as blog_posts__id,
          "blog_posts"."public" as blog_posts__public,
          "blog_posts"."title" as blog_posts__title,
          "blog_posts"."blog_id" as blog_posts__blog_id
        FROM
          "blog_posts"
        LIMIT 5
        OFFSET 2
      """)

  describe "unions", ->
    it "constructs a set union query", ->
      left = blogPosts.where(blogId: 5)
      right = blogPosts.where(public: true)
      relation = left.union(right)
      expect(relation.toSql()).toBeLikeQuery("""
        SELECT
          "blog_posts"."id" as blog_posts__id,
          "blog_posts"."public" as blog_posts__public,
          "blog_posts"."title" as blog_posts__title,
          "blog_posts"."blog_id" as blog_posts__blog_id
        FROM
          "blog_posts"
        WHERE
          "blog_posts"."blog_id" = 5
        UNION
        SELECT
          "blog_posts"."id" as blog_posts__id,
          "blog_posts"."public" as blog_posts__public,
          "blog_posts"."title" as blog_posts__title,
          "blog_posts"."blog_id" as blog_posts__blog_id
        FROM
          "blog_posts"
        WHERE
          "blog_posts"."public" = true
      """)

  describe "differences", ->
    it "constructs a set difference query", ->
      left = blogPosts.where(blogId: 5)
      right = blogPosts.where(public: true)
      relation = left.difference(right)
      expect(relation.toSql()).toBeLikeQuery("""
        SELECT
          "blog_posts"."id" as blog_posts__id,
          "blog_posts"."public" as blog_posts__public,
          "blog_posts"."title" as blog_posts__title,
          "blog_posts"."blog_id" as blog_posts__blog_id
        FROM
          "blog_posts"
        WHERE
          "blog_posts"."blog_id" = 5
        EXCEPT
        SELECT
          "blog_posts"."id" as blog_posts__id,
          "blog_posts"."public" as blog_posts__public,
          "blog_posts"."title" as blog_posts__title,
          "blog_posts"."blog_id" as blog_posts__blog_id
        FROM
          "blog_posts"
        WHERE
          "blog_posts"."public" = true
      """)

  describe "joins", ->
    describe "a join between two tables", ->
      it "constructs a join query", ->
        relation = blogs.join(blogPosts)
        expect(relation.toSql()).toBeLikeQuery("""
          SELECT
            "blogs"."id" as blogs__id,
            "blogs"."public" as blogs__public,
            "blogs"."title" as blogs__title,
            "blogs"."author_id" as blogs__author_id,
            "blog_posts"."id" as blog_posts__id,
            "blog_posts"."public" as blog_posts__public,
            "blog_posts"."title" as blog_posts__title,
            "blog_posts"."blog_id" as blog_posts__blog_id
          FROM
            "blogs"
          INNER JOIN
            "blog_posts"
          ON
            "blogs"."id" = "blog_posts"."blog_id"
        """)

    describe "a join between a table and a limit", ->
      it "makes a subquery for a limit on the left", ->
        relation = blogs.limit(10).join(blogPosts)
        expect(relation.toSql()).toBeLikeQuery("""
          SELECT
            "t1"."blogs__id",
            "t1"."blogs__public",
            "t1"."blogs__title",
            "t1"."blogs__author_id",
            "blog_posts"."id" as blog_posts__id,
            "blog_posts"."public" as blog_posts__public,
            "blog_posts"."title" as blog_posts__title,
            "blog_posts"."blog_id" as blog_posts__blog_id
          FROM
            (
              SELECT
                "blogs"."id" as blogs__id,
                "blogs"."public" as blogs__public,
                "blogs"."title" as blogs__title,
                "blogs"."author_id" as blogs__author_id
              FROM
                "blogs"
              LIMIT
                10
            ) as "t1"
          INNER JOIN
            "blog_posts"
          ON
            "t1"."blogs__id" = "blog_posts"."blog_id"
        """)

      it "makes a subquery for a limit on the right", ->
        relation = blogs.join(blogPosts.limit(10))
        expect(relation.toSql()).toBeLikeQuery("""
          SELECT
            "blogs"."id" as blogs__id,
            "blogs"."public" as blogs__public,
            "blogs"."title" as blogs__title,
            "blogs"."author_id" as blogs__author_id,
            "t1"."blog_posts__id",
            "t1"."blog_posts__public",
            "t1"."blog_posts__title",
            "t1"."blog_posts__blog_id"
          FROM
            "blogs"
          INNER JOIN
            (
              SELECT
                "blog_posts"."id" as blog_posts__id,
                "blog_posts"."public" as blog_posts__public,
                "blog_posts"."title" as blog_posts__title,
                "blog_posts"."blog_id" as blog_posts__blog_id
              FROM
                "blog_posts"
              LIMIT
                10
            ) as "t1"
          ON
            "blogs"."id" = "t1"."blog_posts__blog_id"
        """)

    describe "a join between a selection and a table", ->
      it "makes a subquery for a selection on the left", ->
        relation = blogs.where(public: true).join(blogPosts)
        expect(relation.toSql()).toBeLikeQuery("""
          SELECT
            "t1"."blogs__id",
            "t1"."blogs__public",
            "t1"."blogs__title",
            "t1"."blogs__author_id",
            "blog_posts"."id" as blog_posts__id,
            "blog_posts"."public" as blog_posts__public,
            "blog_posts"."title" as blog_posts__title,
            "blog_posts"."blog_id" as blog_posts__blog_id
          FROM
            (
              SELECT
                "blogs"."id" as blogs__id,
                "blogs"."public" as blogs__public,
                "blogs"."title" as blogs__title,
                "blogs"."author_id" as blogs__author_id
              FROM
                "blogs"
              WHERE
                "blogs"."public" = true
            ) as "t1"
          INNER JOIN
            "blog_posts"
          ON
            "t1"."blogs__id" = "blog_posts"."blog_id"
        """)

      it "makes a subquery for a selection on the right", ->
        relation = blogs.join(blogPosts.where(public: true))
        expect(relation.toSql()).toBeLikeQuery("""
          SELECT
            "blogs"."id" as blogs__id,
            "blogs"."public" as blogs__public,
            "blogs"."title" as blogs__title,
            "blogs"."author_id" as blogs__author_id,
            "t1"."blog_posts__id",
            "t1"."blog_posts__public",
            "t1"."blog_posts__title",
            "t1"."blog_posts__blog_id"
          FROM
            "blogs"
          INNER JOIN
            (
              SELECT
                "blog_posts"."id" as blog_posts__id,
                "blog_posts"."public" as blog_posts__public,
                "blog_posts"."title" as blog_posts__title,
                "blog_posts"."blog_id" as blog_posts__blog_id
              FROM
                "blog_posts"
              WHERE
                "blog_posts"."public" = true
            ) as "t1"
          ON
            "blogs"."id" = "t1"."blog_posts__blog_id"
        """)

  describe "projections", ->
    it "constructs a projected join query", ->
      relation = blogs.joinThrough(blogPosts)
      expect(relation.toSql()).toBeLikeQuery("""
        SELECT
          "blog_posts"."id" as blog_posts__id,
          "blog_posts"."public" as blog_posts__public,
          "blog_posts"."title" as blog_posts__title,
          "blog_posts"."blog_id" as blog_posts__blog_id
        FROM
          "blogs"
        INNER JOIN
          "blog_posts"
        ON
          "blogs"."id" = "blog_posts"."blog_id"
      """)
