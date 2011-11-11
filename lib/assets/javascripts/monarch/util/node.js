(function(Monarch) {
  Monarch.Util.Node = new JS.Class('Monarch.Util.Node', {
    extend: JS.Forwardable,

    initialize: function() {
      this.clear();
    },

    clear: function() {
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
      return new Monarch.Util.Subscription(callback, context, this).tap(function(subscription) {
        this._subscriptions.add(subscription);
      }, this);
    },

    unsubscribe: function(subscription) {
      this._subscriptions.remove(subscription);
      if (this._emptyNode && this.size() === 0) this._emptyNode.publish();
    },

    onEmpty: function(callback, context) {
      if (!this._emptyNode) this._emptyNode = new Monarch.Util.Node();
      return this._emptyNode.subscribe(callback, context);
    }
  });

  Monarch.Util.Node.defineDelegator('_subscriptions', 'length', 'size');
})(Monarch);
