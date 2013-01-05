{ root, _, databaseConfig } = require "./spec_helper"
ConnectionPool = require "#{root}/connection_pool"

describe "ConnectionPool", ->
  connectionPool = null

  beforeEach ->
    connectionPool = new ConnectionPool

  describe ".query", ->
    describe "when the connection is not configured", ->
      it "calls the callback with an error indicating the missing options", (done) ->
        connectionPool.query 'select 1', (err, result) ->
          expect(err.message).toMatch(/Missing.*host.*port/)
          done()

    describe "when connecting to the database fails", ->
      beforeEach ->
        connectionPool.configure(
          _.extend({}, databaseConfig, host: 'totally-wrong'))

      it "calls the callback with a connection error", (done) ->
        connectionPool.query 'select 1', (err, result) ->
          expect(err.message).toMatch(/getaddrinfo/)
          done()

    describe "when connecting to the database succeeds", ->
      beforeEach ->
        connectionPool.configure(databaseConfig)

      describe "when the query fails", ->
        it "calls the callback with the error", (done) ->
          connectionPool.query 'nonsense', (err, result) ->
            expect(err.message).toMatch(/syntax.*error.*nonsense/)
            done()

      describe "when the query succeeds", ->
        it "calls the callback with the error", (done) ->
          connectionPool.query 'select 1 as "one"', (err, result) ->
            expect(err).toBeNull()
            expect(result.rows).toEqual([{one: 1}])
            done()
