{ underscore } = Monarch.Util.Inflection

class Monarch.Remote.MutateRequest extends Monarch.Util.Deferrable
  constructor: (@record, @fieldValues) ->
    super()
    Monarch.Repository.pauseUpdates()
    @perform()

  perform: ->
    data = @requestData()
    data = @convertKeysToSnakeCase(data) if Monarch.snakeCase and data?

    jQuery.ajax
      url: @requestUrl()
      type: @requestType
      data: data
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

  convertKeysToSnakeCase: (data) ->
    fieldValues = {}
    for key, value of data.fieldValues
      fieldValues[underscore(key)] = value
    { field_values: fieldValues }
