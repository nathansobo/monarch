class Monarch.Util.Node
  constructor: ->
    @clear()

  clear: ->
    @subscriptions = new JS.Set()

  publish: ->
    @publishArgs(arguments)

  publishArgs: (args) ->
    @subscriptions.forEach (subscription) ->
      subscription.publish(args)

  subscribe: (callback, context) ->
    subscription = new Monarch.Util.Subscription(callback, context, this)
    @subscriptions.add(subscription)
    subscription

  unsubscribe: (subscription) ->
    @subscriptions.remove(subscription)
    @emptyNode?.publish() if @size() == 0

  onEmpty: (callback, context) ->
    @emptyNode ?= new Monarch.Util.Node()
    @emptyNode.subscribe(callback, context)

  length: ->
    @subscriptions.length

  size: ->
    @subscriptions.size
