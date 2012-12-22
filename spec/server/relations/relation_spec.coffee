{ Monarch, async, pg } = require "../spec_helper"

describe "Relation", ->
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
      blogId: 'integer'
      title: 'string'

  class Comment extends Monarch.Record
    @extended(this)
    @columns
      body: 'string'
      blogPostId: 'integer'
      authorId: 'integer'

  beforeEach (done) ->
    blogs = Blog.table
    blogPosts = BlogPost.table
    comments = Comment.table

    Monarch.Db.Connection.query("""
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

      INSERT INTO comments (id, body, blog_post_id, author_id)
      VALUES
      (1, 'Comment1', 1, 1),
      (2, 'Comment2', 1, 1),
      (3, 'Comment3', 2, 1),
      (4, 'Comment4', 2, 1);
    """, done)

  describe "#all", ->
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
            sortedTuples = _.sortBy tuples, (t) -> [t.left.id(), t.right.id()]
            expect(sortedTuples).toEqualCompositeTuples(
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

      describe "a left-associative three table join", ->
        it "builds composite tuples with the correct left and right records", (done) ->
          blogs.join(blogPosts).join(comments).all (err, tuples) ->
            sortedTuples = _.sortBy tuples, (t) -> [t.left.left.id(), t.left.right.id()]
            leftTuples = (t.left for t in sortedTuples)
            rightTuples = (t.right for t in sortedTuples)

            expect(leftTuples).toEqualCompositeTuples(
              Blog, [
                { id: 1, public: true, title: 'Public Blog1', authorId: 1 }
                { id: 1, public: true, title: 'Public Blog1', authorId: 1 }
                { id: 2, public: true, title: 'Public Blog2', authorId: 1 }
                { id: 2, public: true, title: 'Public Blog2', authorId: 1 }
              ],
              BlogPost, [
                { id: 1, public: true, title: 'Public Post1', blogId: 1 }
                { id: 1, public: true, title: 'Public Post1', blogId: 1 }
                { id: 2, public: true, title: 'Public Post2', blogId: 2 }
                { id: 2, public: true, title: 'Public Post2', blogId: 2 }
              ])
            expect(rightTuples).toEqualRecords(
              Comment, [
                { id: 1, body: 'Comment1', blogPostId: 1, authorId: 1 }
                { id: 2, body: 'Comment2', blogPostId: 1, authorId: 1 }
                { id: 3, body: 'Comment3', blogPostId: 2, authorId: 1 }
                { id: 4, body: 'Comment4', blogPostId: 2, authorId: 1 }
              ])
            done()

      describe "a right-associative three table join", ->
        it "builds composite tuples with the correct left and right records", (done) ->
          blogs.join(blogPosts.join(comments)).all (err, tuples) ->
            sortedTuples = _.sortBy tuples, (t) -> [t.left.id(), t.right.left.id()]
            leftTuples = (t.left for t in sortedTuples)
            rightTuples = (t.right for t in sortedTuples)

            expect(leftTuples).toEqualRecords(
              Blog, [
                { id: 1, public: true, title: 'Public Blog1', authorId: 1 }
                { id: 1, public: true, title: 'Public Blog1', authorId: 1 }
                { id: 2, public: true, title: 'Public Blog2', authorId: 1 }
                { id: 2, public: true, title: 'Public Blog2', authorId: 1 }
              ])
            expect(rightTuples).toEqualCompositeTuples(
              BlogPost, [
                { id: 1, public: true, title: 'Public Post1', blogId: 1 }
                { id: 1, public: true, title: 'Public Post1', blogId: 1 }
                { id: 2, public: true, title: 'Public Post2', blogId: 2 }
                { id: 2, public: true, title: 'Public Post2', blogId: 2 }
              ],
              Comment, [
                { id: 1, body: 'Comment1', blogPostId: 1, authorId: 1 }
                { id: 2, body: 'Comment2', blogPostId: 1, authorId: 1 }
                { id: 3, body: 'Comment3', blogPostId: 2, authorId: 1 }
                { id: 4, body: 'Comment4', blogPostId: 2, authorId: 1 }
              ])
            done()

    describe "projections", ->
      it "builds a the right record class", (done) ->
        blogs.joinThrough(blogPosts).all (err, records) ->
          sortedRecords = _.sortBy records, (r) -> r.id()
          expect(sortedRecords).toEqualRecords(BlogPost, [
            { id: 1, public: true, title: 'Public Post1', blogId: 1 }
            { id: 2, public: true, title: 'Public Post2', blogId: 2 }
            { id: 3, public: false, title: 'Private Post1', blogId: 1 }
            { id: 4, public: false, title: 'Private Post2', blogId: 2 }
          ])
          done()

    describe "unions", ->
      it "builds a the right record class", (done) ->
        blogs.limit(2).union(blogs.limit(2, 1)).all (err, records) ->
          sortedRecords = _.sortBy records, (r) -> r.id()
          expect(sortedRecords).toEqualRecords(Blog, [
            { id: 1, public: true, title: 'Public Blog1', authorId: 1 }
            { id: 2, public: true, title: 'Public Blog2', authorId: 1 }
            { id: 3, public: false, title: 'Private Blog1', authorId: 1 }
          ])
          done()

    describe "differences", ->
      it "builds a the right record class", (done) ->
        blogs.limit(2).difference(blogs.limit(2, 1)).all (err, records) ->
          sortedRecords = _.sortBy records, (r) -> r.id()
          expect(sortedRecords).toEqualRecords(Blog, [
            { id: 1, public: true, title: 'Public Blog1', authorId: 1 }
          ])
          done()
