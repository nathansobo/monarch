#= require ./mutate_request

class Monarch.Remote.CreateRequest extends Monarch.Remote.MutateRequest
  requestType: 'post',

  requestUrl: ->
    Monarch.sandboxUrl + '/' + @record.table.urlName()

  requestData: ->
    return { @fieldValues } unless _.isEmpty(@fieldValues)

  triggerSuccess: (attributes) ->
    @record.created(attributes)
    super(@record)
