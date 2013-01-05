_ = require 'underscore'

beforeEach ->
  Monarch.configureConnection(databaseConfig)
  @addMatchers
    toBeA: (constructor) ->
      @message = -> [
        "Expected #{@actual} to be an instance of #{constructor.name}",
        "Expected #{@actual} not to be an instance of #{constructor.name}"
      ]
      @actual instanceof constructor

    toBeLikeQuery: (sql) ->
      normalizedActual = normalizeSql(@actual)
      normalizedExpected = normalizeSql(sql)

      @message = -> [
        "\nExpected this query:\n\n  #{normalizedActual} \n\nto be like this query:\n\n  #{normalizedExpected}\n",
        "\nExpected two different queries. Both were like this:\n\n  #{normalizedActual}\n",
      ]
      normalizedActual == normalizedExpected

    toEqualRecords: (recordClass, attrHashes) ->
      if message = recordArrayMatcherMessage(@actual, attrHashes.length)
        @message = -> message
        return false
      for record, i in @actual
        if message = recordMatcherMessage(record, recordClass, attrHashes[i])
          @message = -> message
          return false
      true

    toEqualRecord: (recordClass, attrs) ->
      if message = recordMatcherMessage(@actual, recordClass, attrs)
        @message = -> message
        false
      else
        true

    toEqualCompositeTuples: (leftClass, leftAttrHashes, rightClass, rightAttrHashes) ->
      if (rightAttrHashes.length isnt leftAttrHashes.length)
        throw new Error("Test error - non-matching number of rows")
      if message = recordArrayMatcherMessage(@actual, leftAttrHashes.length)
        @message = -> message
        return false
      for tuple, i in @actual
        { left, right } = tuple
        if message = recordMatcherMessage(left, leftClass, leftAttrHashes[i])
          @message = -> message
          return false
        if message = recordMatcherMessage(right, rightClass, rightAttrHashes[i])
          @message = -> message
          return false
      true

recordArrayMatcherMessage = (records, n) ->
  unless records
    return "Expected an array of records. Got #{records}."
  unless (records.length == n)
    return "\nExpected this:\n\n#{records}\n\nto contain #{n} tuples, not #{records.length}.\n"

recordMatcherMessage = (record, recordClass, attrs) ->
  unless record instanceof recordClass
    return "\nExpected this record:  #{record}\nto be an instance of #{recordClass.name}.\n"
  unless _.isEqual(record.fieldValues(), attrs)
    return "\nExpected this record:  #{record}\nto have these attributes:  #{JSON.stringify(attrs)}\n"

normalizeSql = (string) ->
  string
    .replace(/\s+/g, ' ')
    .replace(/\(\s+/g, '(')
    .replace(/\s+\)/g, ')')
    .replace(/\s$/g, '')
    .replace(/^\s/g, '')

databaseConfig = require "./support/database"
root = "#{__dirname}/../../lib/server"
Monarch = require "#{root}/index"

module.exports =
  root: root
  databaseConfig: databaseConfig
  Monarch: Monarch
  _: _
  async: require 'async'
  pg: require 'pg'
