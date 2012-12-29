Monarch.Relations.Table.reopen ->
  clear: ->
    Monarch.Events.clear(this)
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

  initialize: ->
    Monarch.Events.activate(this)
