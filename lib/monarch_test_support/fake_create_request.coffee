class Monarch.Remote.FakeCreateRequest extends Monarch.Remote.CreateRequest
  perform: ->

  constructor: (@fakeServer, record, fieldValues) ->
    @fakeServer = fakeServer
    super(record, fieldValues)
    fakeServer.creates.push(this)

  succeed: (fieldValues = _.clone(@fieldValues)) ->
    recordWithHighestId = @record.table.orderBy('id desc').first()
    fieldValues.id ?= (recordWithHighestId?.id() ? 0) + 1
    @fakeServer.creates = _.without(@fakeServer.creates, this)
    @triggerSuccess(fieldValues)
