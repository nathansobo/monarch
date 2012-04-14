class Monarch.Remote.UpdateRequest extends Monarch.Remote.MutateRequest
  requestType: 'put'

  requestUrl: ->
    Monarch.sandboxUrl + '/' + @record.table.urlName() + '/' + @record.id()

  requestData: ->
    { @fieldValues }

  triggerSuccess: (attributes) ->
    changeset = @record.updated(attributes)
    super(@record, changeset)
