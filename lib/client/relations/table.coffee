_.extend Monarch.Relations.Table.prototype,
  clear: ->
    @_insertNode.clear()
    @_updateNode.clear()
    @_removeNode.clear()
    @_contents = @buildContents()

  defaultOrderBy: ->
    @orderByExpressions = @buildOrderByExpressions(_.toArray(arguments))
    @_contents = @buildContents()

  findOrFetch: (id) ->
    record = @find(id)
    promise = new Monarch.Util.Promise
    if record
      promise.triggerSuccess(record)
    else
      Monarch.Remote.Server.fetch(@where({ id })).onSuccess =>
        record = @find(id)
        promise.triggerSuccess(record)
    promise
