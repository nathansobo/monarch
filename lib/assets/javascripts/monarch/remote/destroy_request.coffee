class Monarch.Remote.DestroyRequest extends Monarch.Remote.MutateRequest
  requestType: 'delete',

  requestUrl: ->
    @record.table.resourceUrl() + '/' + @record.id()

  requestData: ->

  triggerSuccess: ->
    @record.destroyed()
    super(@record)
