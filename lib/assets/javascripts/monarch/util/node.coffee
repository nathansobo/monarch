class Monarch.Util.Node
  constructor: ->
    @clear()

  clear: ->
    @_subscriptions = new JS.Set()

  publish: ->
    @publishArgs(arguments)

  publishArgs: (args) ->
    @_subscriptions.forEach (subscription) ->
      subscription.publish(args)

  subscribe: (callback, context) ->
    subscription = new Monarch.Util.Subscription(callback, context, this)
    @_subscriptions.add(subscription)
    subscription

  unsubscribe: (subscription) ->
    @_subscriptions.remove(subscription)
    @_emptyNode?.publish() if @size() == 0

  onEmpty: (callback, context) ->
    @_emptyNode ?= new Monarch.Util.Node()
    @_emptyNode.subscribe(callback, context)

  length: ->
    @_subscriptions.length

  size: ->
    @_subscriptions.size
