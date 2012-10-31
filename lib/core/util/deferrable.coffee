class Monarch.Util.Deferrable
  constructor: ->
    @_deferrableNodes = {}
    @_deferrableData = {}
    @_deferrableTriggerred = {}

  onSuccess: (callback, context) ->
    @on('success', callback, context)

  success: (args...) -> @onSuccess(args...)

  onInvalid: (callback, context) ->
    @on('invalid', callback, context)

  onError: (callback, context) ->
    @on('error', callback, context)

  triggerSuccess: ->
    @trigger('success', arguments)

  triggerInvalid: ->
    @trigger('invalid', arguments)

  triggerError: ->
    @trigger('error', arguments)

  on: (eventName, callback, context) ->
    if @_deferrableTriggerred[eventName]?
      callback.apply(context, @_deferrableData[eventName])
    else
      node = (@_deferrableNodes[eventName] ?= new Monarch.Util.Node())
      node.subscribe(callback, context)
    this

  trigger: (eventName, data) ->
    @_deferrableTriggerred[eventName] = true
    @_deferrableData[eventName] = data
    @_deferrableNodes[eventName]?.publishArgs(data)
