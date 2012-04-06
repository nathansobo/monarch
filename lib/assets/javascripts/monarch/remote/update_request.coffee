class Monarch.Remote.UpdateRequest extends Monarch.Remote.MutateRequest
  requestType: 'put'

  requestUrl: ->
    Monarch.sandboxUrl + '/' + @record.table.remoteName + '/' + @record.id()

  requestData: ->
    { field_values: @fieldValues }

  triggerSuccess: (attributes) ->
    changeset = @record.updated(_.camelizeKeys(attributes))
    super(@record, changeset)
