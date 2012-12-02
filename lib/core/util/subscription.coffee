class Monarch.Util.Subscription
  constructor: (@callback, @context, @node) ->

  publish: (args) ->
    @callback.apply(@context, args)

  destroy: ->
    @node.unsubscribe(this)
