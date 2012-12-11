{ Monarch, async, pg } = require "../spec_helper"

describe "Db.RecordRetriever", ->
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

  beforeEach (done) ->
    blogs = Blog.table
    blogPosts = BlogPost.table

    Monarch.Db.query("""
      TRUNCATE TABLE blogs;
      TRUNCATE TABLE blog_posts;
      TRUNCATE TABLE comments;

      INSERT INTO blogs (id, public, title, author_id)
      VALUES
      (1, true, 'Public Blog1', 1),
      (2, true, 'Public Blog2', 1),
      (3, false, 'Private Blog1', 1);

      INSERT INTO blog_posts (id, public, title, blog_id)
      VALUES
      (1, true, 'Public Post1', 1),
      (2, true, 'Public Post2', 2),
      (3, false, 'Private Post1', 1),
      (4, false, 'Private Post2', 2);
    """, done)

  describe "tables", ->
    it "builds the table's record class", (done) ->
      blogPosts.all (err, records) ->
        expect(records).toEqualRecords(BlogPost, [
          { id: 1, public: true, title: 'Public Post1', blogId: 1 }
          { id: 2, public: true, title: 'Public Post2', blogId: 2 }
          { id: 3, public: false, title: 'Private Post1', blogId: 1 }
          { id: 4, public: false, title: 'Private Post2', blogId: 2 }
        ])
        done()

  describe "selections", ->
    it "builds the right record class", (done) ->
      blogPosts.where(public: true).all (err, records) ->
        expect(records).toEqualRecords(BlogPost, [
          { id: 1, public: true, title: 'Public Post1', blogId: 1 }
          { id: 2, public: true, title: 'Public Post2', blogId: 2 }
        ])
        done()

  describe "orderings", ->
    describe "an ordering on a table", ->
      it "builds the right record class", (done) ->
        blogPosts.orderBy('id desc').all (err, records) ->
          expect(records).toEqualRecords(BlogPost, [
            { id: 4, public: false, title: 'Private Post2', blogId: 2 }
            { id: 3, public: false, title: 'Private Post1', blogId: 1 }
            { id: 2, public: true, title: 'Public Post2', blogId: 2 }
            { id: 1, public: true, title: 'Public Post1', blogId: 1 }
          ])
          done()

    describe "an ordering on a limit", ->
      it "adds the correct order by clause", (done) ->
        blogPosts.limit(2).orderBy('id desc').all (err, records) ->
          expect(records).toEqualRecords(BlogPost, [
            { id: 2, public: true, title: 'Public Post2', blogId: 2 }
            { id: 1, public: true, title: 'Public Post1', blogId: 1 }
          ])
          done()

  describe "limits", ->
    it "builds the right record class", (done) ->
      blogs.limit(2).all (err, records) ->
        expect(records).toEqualRecords(Blog, [
          { id: 1, public: true, title: 'Public Blog1', authorId: 1 }
          { id: 2, public: true, title: 'Public Blog2', authorId: 1 }
        ])
        done()

  describe "offsets", ->
    it "builds the right record class", (done) ->
      blogPosts.offset(2).all (err, records) ->
        expect(records).toEqualRecords(BlogPost, [
          { id: 3, public: false, title: 'Private Post1', blogId: 1 }
          { id: 4, public: false, title: 'Private Post2', blogId: 2 }
        ])
        done()

  describe "joins", ->
    describe "a join between two tables", ->
      it "builds composite tuples with the correct left and right records", (done) ->
        blogs.join(blogPosts).all (err, tuples) ->
          expect(tuples).toEqualCompositeTuples(
            Blog, [
              { id: 1, public: true, title: 'Public Blog1', authorId: 1 }
              { id: 1, public: true, title: 'Public Blog1', authorId: 1 }
              { id: 2, public: true, title: 'Public Blog2', authorId: 1 }
              { id: 2, public: true, title: 'Public Blog2', authorId: 1 }
            ],
            BlogPost, [
              { id: 1, public: true, title: 'Public Post1', blogId: 1 }
              { id: 3, public: false, title: 'Private Post1', blogId: 1 }
              { id: 2, public: true, title: 'Public Post2', blogId: 2 }
              { id: 4, public: false, title: 'Private Post2', blogId: 2 }
            ])
          done()

    describe "a join between a limit and a table", ->
      it "builds composite tuples with the correct left and right records", (done) ->
        blogs.limit(1).join(blogPosts).all (err, tuples) ->
          expect(tuples).toEqualCompositeTuples(
            Blog, [
              { id: 1, public: true, title: 'Public Blog1', authorId: 1 }
              { id: 1, public: true, title: 'Public Blog1', authorId: 1 }
            ],
            BlogPost, [
              { id: 1, public: true, title: 'Public Post1', blogId: 1 }
              { id: 3, public: false, title: 'Private Post1', blogId: 1 }
            ])
          done()

    describe "a join between a selection and a table", ->
      it "builds composite tuples with the correct left and right records", (done) ->
        blogs.where(title: 'Public Blog1').join(blogPosts).all (err, tuples) ->
          expect(tuples).toEqualCompositeTuples(
            Blog, [
              { id: 1, public: true, title: 'Public Blog1', authorId: 1 }
              { id: 1, public: true, title: 'Public Blog1', authorId: 1 }
            ],
            BlogPost, [
              { id: 1, public: true, title: 'Public Post1', blogId: 1 }
              { id: 3, public: false, title: 'Private Post1', blogId: 1 }
            ])
          done()

  describe "projections", ->
    it "builds a the right record class", (done) ->
      blogs.joinThrough(blogPosts).all (err, records) ->
        expect(records).toEqualRecords(BlogPost, [
          { id: 1, public: true, title: 'Public Post1', blogId: 1 }
          { id: 3, public: false, title: 'Private Post1', blogId: 1 }
          { id: 2, public: true, title: 'Public Post2', blogId: 2 }
          { id: 4, public: false, title: 'Private Post2', blogId: 2 }
        ])
        done()
