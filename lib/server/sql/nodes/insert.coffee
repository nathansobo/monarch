module.exports = class Insert
  constructor: (@table, @columns, @valueLists) ->

  toSql: ->
    [
      "INSERT INTO",
      @table.toSql(),
      @columnsClause(),
      "VALUES",
      @valuesClause()
    ].join(' ')

  columnsClause: ->
    parenthesizedList(@columns)

  valuesClause: ->
    lists = for valueList in @valueLists
      sqlValueList = (@sqlize(value) for value in valueList)
      parenthesizedList(sqlValueList)
    lists.join(', ')

  sqlize: (value) ->
    value

parenthesizedList = (elements) ->
  parts = (element.toSql() for element in elements)
  [
    '(',
    parts.join(', '),
    ')'
  ].join(' ')

