{ Monarch, async, pg } = require "../spec_helper"

describe "Relations.Selection", ->
  class Blog extends Monarch.Record
    @extended(this)
    @columns
      public: 'boolean'
      title: 'string'
      authorId: 'integer'

  blogs = Blog.table
  selection = null

  beforeEach (done) ->
    selection = blogs.where(authorId: 5)
    Monarch.Db.Connection.query("TRUNCATE TABLE blogs;", done)

  describe "#create", ->
    describe "when a single attribute hash is passed", ->
      it "inserts a record that satisifies the selection", (done) ->
        selection.create { id: 1, public: false, title: "New Blog 1" }, ->
          blogs.first (err, record) ->
            expect(record).toEqualRecord(Blog,
              id: 1,
              public: false,
              title: "New Blog 1",
              authorId: 5
            )
            done()

    describe "when an array of attribute hashes is passed", ->
      hashes = null

      beforeEach ->
        hashes = [
          { id: 1, public: false, title: 'New Blog 1' }
          { id: 2, public: true, title: 'New Blog 2' }
        ]

      it "inserts a record with each set of attributes", (done) ->
        selection.create hashes, ->
          blogs.all (err, records) ->
            expect(records).toEqualRecords(Blog, [
              { id: 1, public: false, title: "New Blog 1", authorId: 5 }
              { id: 2, public: true, title: "New Blog 2", authorId: 5 }
            ])
            done()

      it "passes the number of records created", (done) ->
        selection.create hashes, (err, result) ->
          expect(result).toBe(2)
          done()

  describe "#updateAll", ->
    beforeEach (done) ->
      blogs.create([
        { id: 1, public: true, title: "Blog 1", authorId: 5 }
        { id: 2, public: true, title: "Blog 2", authorId: 5 }
        { id: 3, public: true, title: "Blog 3", authorId: 6 }
      ], done)

    it "updates all records in the table with the given attributes", (done) ->
      selection.updateAll { public: null }, ->
        blogs.orderBy("id asc").all (err, records) ->
          expect(records).toEqualRecords(Blog, [
            { id: 1, public: null, title: "Blog 1", authorId: 5 }
            { id: 2, public: null, title: "Blog 2", authorId: 5 }
            { id: 3, public: true, title: "Blog 3", authorId: 6 }
          ])
          done()

    it "passes the number of records updated", (done) ->
      selection.updateAll { public: null }, (err, result) ->
        expect(result).toBe(2)
        done()

