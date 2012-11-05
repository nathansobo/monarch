class Monarch.Remote.CreateRequest extends Monarch.Remote.MutateRequest
  requestType: 'post',

  requestUrl: ->
    @record.table.resourceUrl()

  requestData: ->
    return { @fieldValues } unless _.isEmpty(@fieldValues)

  triggerSuccess: (attributes) ->
    @record.created(attributes)
    super(@record)
