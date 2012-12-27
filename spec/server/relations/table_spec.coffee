{ Monarch, async, pg } = require "../spec_helper"

describe "Relations.Table", ->
  class Blog extends Monarch.Record
    @extended(this)
    @columns
      public: 'boolean'
      title: 'string'
      authorId: 'integer'

  blogs = Blog.table

  beforeEach (done) ->
    Monarch.Db.Connection.query("TRUNCATE TABLE blogs;", done)

  describe "#create", ->
    describe "when a single attribute hash is passed", ->
      it "inserts a record with the given attributes", (done) ->
        blogs.create { public: true, title: "New Blog 1", authorId: 11 }, ->
          blogs.find { title: "New Blog 1" }, (err, record) ->
            expect(record.public()).toBeTruthy()
            expect(record.authorId()).toBe(11)
            done()

    describe "when an array of attribute hashes is passed", ->
      it "inserts a record with each set of attributes", (done) ->
        hashes = [
          { id: 1, public: true, title: "New Blog 1", authorId: 11 }
          { id: 2, public: true, title: "New Blog 2", authorId: 12 }
        ]

        blogs.create hashes, ->
          blogs.all (err, records) ->
            expect(records).toEqualRecords(Blog, [
              { id: 1, public: true, title: "New Blog 1", authorId: 11 }
              { id: 2, public: true, title: "New Blog 2", authorId: 12 }
            ])
            done()

