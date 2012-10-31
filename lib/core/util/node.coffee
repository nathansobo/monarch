class Monarch.Util.Node
  constructor: ->
    @clear()

  clear: ->
    @subscriptions = []

  publish: ->
    @publishArgs(arguments)

  publishArgs: (args) ->
    for subscription in @subscriptions
      subscription.publish(args)

  subscribe: (callback, context) ->
    subscription = new Monarch.Util.Subscription(callback, context, this)
    @subscriptions.push(subscription)
    subscription

  unsubscribe: (subscription) ->
    index = @subscriptions.indexOf(subscription)
    @subscriptions.splice(index, 1) unless index == -1
    @emptyNode?.publish() if @size() == 0

  onEmpty: (callback, context) ->
    @emptyNode ?= new Monarch.Util.Node()
    @emptyNode.subscribe(callback, context)

  length: ->
    @subscriptions.length

  size: ->
    @subscriptions.length
