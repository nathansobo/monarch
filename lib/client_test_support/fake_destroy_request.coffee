class Monarch.Remote.FakeDestroyRequest extends Monarch.Remote.DestroyRequest
  perform: ->

  constructor: (@fakeServer, record) ->
    super(record)
    fakeServer.destroys.push(this)

  succeed: ->
    @fakeServer.destroys = _.without(@fakeServer.destroys, this)
    @triggerSuccess()
