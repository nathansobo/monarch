Monarch.Remote.Server =
  create: (record, wireRepresentation) ->
    request = new Monarch.Remote.CreateRequest(record, wireRepresentation)
    if $.ajaxSettings.async then request else request.record

  update: (record, wireRepresentation) ->
    if record.isDirty()
      promise = new Monarch.Remote.UpdateRequest(record, wireRepresentation)
    else
      promise = new Monarch.Util.Deferrable()
      promise.triggerSuccess(record)

    if $.ajaxSettings.async then promise else record

  destroy: (record) ->
    new Monarch.Remote.DestroyRequest(record)

  fetch: (relationOrArray) ->
    relations = if _.isArray(relationOrArray) then relationOrArray else _.toArray(arguments)
    new Monarch.Remote.FetchRequest(relations)
