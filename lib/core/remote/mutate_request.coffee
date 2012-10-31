{ convertKeysToSnakeCase, convertKeysToCamelCase } = Monarch.Util.Inflection

class Monarch.Remote.MutateRequest extends Monarch.Util.Deferrable
  constructor: (@record, @fieldValues) ->
    super()
    Monarch.Repository.pauseUpdates()
    @perform()

  perform: ->
    data = @requestData()
    data = convertKeysToSnakeCase(data) if Monarch.snakeCase and data?

    jQuery.ajax
      url: @requestUrl()
      type: @requestType
      data: data
      dataType: 'json'
      success: (data) => @handleSuccess(data)
      error: (data) => @handleError(data)

  handleSuccess: (data) ->
    data = convertKeysToCamelCase(data) if Monarch.snakeCase and data?
    @triggerSuccess(data)

  handleError: (error) ->
    if error.status == 422
      data = JSON.parse(error.responseText)
      data = convertKeysToCamelCase(data) if Monarch.snakeCase
      @triggerInvalid(data)

  triggerSuccess: ->
    super
    Monarch.Repository.resumeUpdates()

  triggerInvalid: (errors) ->
    @record.errors.assign(errors)
    super(@record)
    Monarch.Repository.resumeUpdates()
