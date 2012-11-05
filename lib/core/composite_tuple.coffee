class Monarch.CompositeTuple
  constructor: (@left, @right) ->

  getField: (name) ->
    @left.getField(name) or @right.getField(name)

  getFieldValue: (name) ->
    @getField(name).getValue()

  getRecord: (tableName) ->
    @left.getRecord(tableName) or @right.getRecord(tableName)

  toString: ->
    "<" + @constructor.displayName + " left:" + @left.toString() + " right:" + @right.toString() + ">"
