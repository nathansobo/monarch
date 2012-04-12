class Monarch.Util.SubscriptionBundle
  constructor: ->
    @subscriptions = []

  add: (subscription) ->
    @subscriptions.push(subscription)

  destroy: ->
    subscription.destroy() for subscription in @subscriptions
    @subscriptions = []
