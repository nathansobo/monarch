Monarch.Remote.Server =
  create: (record, wireRepresentation) ->
    request = new Monarch.Remote.CreateRequest(record, wireRepresentation)
    if $.ajaxSettings.async then request else request.record

  update: (record, wireRepresentation) ->
    request = new Monarch.Remote.UpdateRequest(record, wireRepresentation)
    if $.ajaxSettings.async then request else request.record

  destroy: (record) ->
    new Monarch.Remote.DestroyRequest(record)

  fetch: (relationOrArray) ->
    relations = if _.isArray(relationOrArray) then relationOrArray else _.toArray(arguments)
    new Monarch.Remote.FetchRequest(relations)
