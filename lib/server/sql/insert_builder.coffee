_ = require "underscore"
Nodes = require "./nodes"
QueryBuilder = require "./query_builder"
{ underscore } = require("../core").Util.Inflection

module.exports = class InsertBuilder extends QueryBuilder
  visit_Relations_Table: (table, hashes) ->
    hashes = [hashes] unless _.isArray(hashes)
    columnNames = _.union((_.keys(hash) for hash in hashes)...)
    valueLists = for hash in hashes
      for columnName in columnNames
        hash[columnName] ? null

    new Nodes.Insert(
      buildTable(table)
      buildColumns(columnNames),
      visitValueLists.call(this, valueLists))

buildTable = (table) ->
  new Nodes.Table(table.resourceName())

buildColumns = (columnNames) ->
  for name in columnNames
    new Nodes.InsertColumn(underscore(name))

visitValueLists = (valueLists) ->
  for list in valueLists
    @visit(value) for value in list
