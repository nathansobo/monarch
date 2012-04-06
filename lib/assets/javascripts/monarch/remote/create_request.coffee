#= require ./mutate_request

class Monarch.Remote.CreateRequest extends Monarch.Remote.MutateRequest
  requestType: 'post',

  requestUrl: ->
    Monarch.sandboxUrl + '/' + @record.table.remoteName

  requestData: ->
    return { field_values: @fieldValues } unless _.isEmpty(@fieldValues)

  triggerSuccess: (attributes) ->
    @record.created(_.camelizeKeys(attributes))
    super(@record)
