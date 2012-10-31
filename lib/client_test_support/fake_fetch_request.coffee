class Monarch.Remote.FakeFetchRequest extends Monarch.Remote.FetchRequest
  constructor: (@fakeServer, relations) ->
    super(relations)
    @fakeServer.fetches.push(this)

  perform: ->

  succeed: (records) ->
    Monarch.Repository.update(records)
    @fakeServer.fetches = _.without(@fakeServer.fetches, this)
    @triggerSuccess()
