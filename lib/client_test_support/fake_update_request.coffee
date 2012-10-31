class Monarch.Remote.FakeUpdateRequest extends Monarch.Remote.UpdateRequest
  perform: ->

  constructor: (@fakeServer, record, fieldValues) ->
    super(record, fieldValues)
    fakeServer.updates.push(this)

  succeed: (fieldValues = _.clone(@fieldValues)) ->
    @fakeServer.updates = _.without(@fakeServer.updates, this)
    @triggerSuccess(fieldValues)
