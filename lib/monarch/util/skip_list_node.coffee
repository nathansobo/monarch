class Monarch.Util.SkipListNode
  constructor: (@level, @key, @value) ->
    @pointer = new Array(level)
    @distance = new Array(level)
