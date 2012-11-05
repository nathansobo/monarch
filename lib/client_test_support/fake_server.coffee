Monarch.Remote.FakeServer =
  constructor: ->
    @reset()

  create: (record, wireRepresentation) ->
    request = new Monarch.Remote.FakeCreateRequest(this, record, wireRepresentation)
    request.succeed() if @auto
    request

  update: (record, wireRepresentation) ->
    request = new Monarch.Remote.FakeUpdateRequest(this, record, wireRepresentation)
    request.succeed() if @auto
    request

  destroy: (record) ->
    request = new Monarch.Remote.FakeDestroyRequest(this, record)
    request.succeed() if @auto
    return request

  fetch: ->
    request = new Monarch.Remote.FakeFetchRequest(this, _.toArray(arguments))
    request.succeed() if @auto
    request

  lastCreate: ->
    _.last(@creates)

  lastUpdate: ->
    _.last(@updates)

  lastDestroy: ->
    _.last(@destroys)

  lastFetch: ->
    _.last(@fetches)

  reset: ->
    @creates = []
    @updates = []
    @destroys = []
    @fetches = []

Monarch.Remote.OriginalServer = Monarch.Remote.Server

Monarch.useFakeServer = (auto) ->
  Monarch.Remote.Server = Monarch.Remote.FakeServer
  Monarch.Remote.Server.reset()
  Monarch.Remote.Server.auto = auto

Monarch.restoreOriginalServer = ->
  Monarch.Remote.Server = Monarch.Remote.OriginalServer
