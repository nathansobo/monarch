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

    async.series([
      (f) -> Monarch.Db.Schema.dropTable('blogs', f)
      (f) -> Monarch.Db.Schema.dropTable('blog_posts', f)
      (f) -> Monarch.Db.Schema.createTable('blogs', {
        id: 'integer',
        public: 'boolean',
        title: 'string',
        authorId: 'integer'
      }, f)
      (f) -> Monarch.Db.Schema.createTable('blog_posts', {
        id: 'integer',
        public: 'boolean',
        title: 'string',
        blogId: 'integer'
      }, f)

      (f) -> Monarch.Db.query("""
        INSERT INTO blogs (id, public, title, author_id)
        VALUES
        (1, true, 'Public Blog1', 1),
        (2, true, 'Public Blog2', 1),
        (3, false, 'Private Blog1', 1)
      """, f)
      (f) -> Monarch.Db.query("""
        INSERT INTO blog_posts (id, public, title, blog_id)
        VALUES
        (1, true, 'Public Post1', 1),
        (2, true, 'Public Post2', 2),
        (3, false, 'Private Post1', 1),
        (4, false, 'Private Post2', 2)
      """, f)
    ], done)

  describe "tables", ->
    it "builds the table's record class", (done) ->
      blogPosts.all (err, records) ->
        rowHashes = [
          { id: 1, public: true, title: 'Public Post1', blogId: 1 }
          { id: 2, public: true, title: 'Public Post2', blogId: 2 }
          { id: 3, public: false, title: 'Private Post1', blogId: 1 }
          { id: 4, public: false, title: 'Private Post2', blogId: 2 }
        ]

        expect(records.length).toBe(4)
        for record, i in records
          expect(record).toBeA(BlogPost)
          expect(record.fieldValues()).toEqual(rowHashes[i])
        done()

  describe "selections", ->
    it "builds the right record class", (done) ->
      blogPosts.where(public: true).all (err, records) ->
        rowHashes = [
          { id: 1, public: true, title: 'Public Post1', blogId: 1 }
          { id: 2, public: true, title: 'Public Post2', blogId: 2 }
        ]

        expect(records.length).toBe(2)
        for record, i in records
          expect(record).toBeA(BlogPost)
          expect(record.fieldValues()).toEqual(rowHashes[i])
        done()

  describe "orderings", ->
    it "builds the right record class", (done) ->
      blogPosts.orderBy('id desc').all (err, records) ->
        rowHashes = [
          { id: 4, public: false, title: 'Private Post2', blogId: 2 }
          { id: 3, public: false, title: 'Private Post1', blogId: 1 }
          { id: 2, public: true, title: 'Public Post2', blogId: 2 }
          { id: 1, public: true, title: 'Public Post1', blogId: 1 }
        ]

        expect(records.length).toBe(4)
        for record, i in records
          expect(record).toBeA(BlogPost)
          expect(record.fieldValues()).toEqual(rowHashes[i])
        done()

  describe "offsets", ->
    it "builds the right record class", (done) ->
      blogPosts.offset(2).all (err, records) ->
        rowHashes = [
          { id: 3, public: false, title: 'Private Post1', blogId: 1 }
          { id: 4, public: false, title: 'Private Post2', blogId: 2 }
        ]

        expect(records.length).toBe(2)
        for record, i in records
          expect(record).toBeA(BlogPost)
          expect(record.fieldValues()).toEqual(rowHashes[i])
        done()

  describe "projections", ->
    it "builds a the right record class", (done) ->
      blogs.joinThrough(blogPosts).all (err, records) ->
        rowHashes = [
          { id: 1, public: true, title: 'Public Post1', blogId: 1 }
          { id: 3, public: false, title: 'Private Post1', blogId: 1 }
          { id: 2, public: true, title: 'Public Post2', blogId: 2 }
          { id: 4, public: false, title: 'Private Post2', blogId: 2 }
        ]

        expect(records.length).toBe(4)
        for record, i in records
          expect(record).toBeA(BlogPost)
          expect(record.fieldValues()).toEqual(rowHashes[i])
        done()
