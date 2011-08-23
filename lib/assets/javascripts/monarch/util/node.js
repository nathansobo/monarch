(function(Monarch) {
  Monarch.Util.Node = new JS.Class('Monarch.Util.Node', {
    initialize: function() {
      this._subscriptions = new JS.Set();
    },

    publish: function() {
      this.publishArgs(arguments);
    },

    publishArgs: function(args) {
      this._subscriptions.forEach(function(subscription) {
        subscription.publish(args);
      });
    },

    subscribe: function(callback, context) {
      return new Monarch.Util.Subscription(callback, context).tap(function(subscription) {
        this._subscriptions.add(subscription);
      }, this);
    }
  });
})(Monarch);
