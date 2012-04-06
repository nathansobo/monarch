class Monarch.Remote.MutateRequest extends Monarch.Util.Deferrable
  constructor: (@record, @fieldValues) ->
    super()
    Monarch.Repository.pauseUpdates()
    @perform()

  perform: ->
    jQuery.ajax
      url: @requestUrl()
      type: @requestType
      data: @requestData()
      dataType: 'json'
      success: (args...) => @triggerSuccess(args...)
      error: (args...) => @handleError(args...)

  triggerSuccess: ->
    super
    Monarch.Repository.resumeUpdates()

  triggerInvalid: (errors) ->
    @record.errors.assign(errors)
    super(@record)
    Monarch.Repository.resumeUpdates()

  handleError: (error) ->
    @triggerInvalid(JSON.parse(error.responseText)) if error.status == 422
