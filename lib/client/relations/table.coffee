_.extend Monarch.Relations.Table.prototype,
  clear: ->
    @_insertNode.clear()
    @_updateNode.clear()
    @_removeNode.clear()
    @_contents = @buildContents()

  defaultOrderBy: ->
    @orderByExpressions = @buildOrderByExpressions(_.toArray(arguments))
    @_contents = @buildContents()
