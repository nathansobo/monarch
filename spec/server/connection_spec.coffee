{ Monarch, async, pg } = require "./spec_helper"

describe "Connection", ->
  { Connection } = Monarch

  describe ".query", ->
    describe "when the connection is not configured", ->
      beforeEach ->
        Connection.configure(host: null, port: null)

      it "calls the callback with an error indicating the missing options", (done) ->
        Connection.query 'select 1', (err, result) ->
          expect(err.message).toMatch(/Missing.*host.*port/)
          done()

    describe "when connecting to the database fails", ->
      beforeEach ->
        Connection.configure(host: 'totally-wrong')

      it "calls the callback with a connection error", (done) ->
        Connection.query 'select 1', (err, result) ->
          expect(err.message).toMatch(/getaddrinfo/)
          done()

    describe "when connecting to the database succeeds", ->
      describe "when the query fails", ->
        it "calls the callback with the error", (done) ->
          Connection.query 'nonsense', (err, result) ->
            expect(err.message).toMatch(/syntax.*error.*nonsense/)
            done()

      describe "when the query succeeds", ->
        it "calls the callback with the error", (done) ->
          Connection.query 'select 1 as "one"', (err, result) ->
            expect(err).toBeNull()
            expect(result.rows).toEqual([{one: 1}])
            done()
