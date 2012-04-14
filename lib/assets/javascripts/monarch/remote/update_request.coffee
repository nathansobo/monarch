class Monarch.Remote.UpdateRequest extends Monarch.Remote.MutateRequest
  requestType: 'put'

  requestUrl: ->
    @record.table.resourceUrl() + '/' + @record.id()

  requestData: ->
    { @fieldValues }

  triggerSuccess: (attributes) ->
    changeset = @record.updated(attributes)
    super(@record, changeset)
