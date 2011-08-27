(function(Monarch) {
  Monarch.Util.Subscription = new JS.Class('Monarch.Util.Subscription', {
    initialize: function(callback, context, node) {
      this.callback = callback;
      this.context = context;
      this.node = node;
    },

    publish: function(args) {
      this.callback.apply(this.context, args);
    },

    destroy: function() {
      this.node.unsubscribe(this);
    }
  })
})(Monarch);
