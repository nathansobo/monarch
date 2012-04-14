class Monarch.Remote.DestroyRequest extends Monarch.Remote.MutateRequest
  requestType: 'delete',

  requestUrl: ->
    Monarch.sandboxUrl + '/' + @record.table.urlName() + '/' + @record.id()

  requestData: ->

  triggerSuccess: ->
    @record.destroyed()
    super(@record)
