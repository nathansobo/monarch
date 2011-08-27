(function(Monarch) {
  Monarch.Util.SubscriptionBundle = new JS.Class('Monarch.Util.SubscriptionBundle', {
    initialize: function() {
      this.subscriptions = [];
    },

    add: function(subscription) {
      this.subscriptions.push(subscription);
    },

    destroy: function() {
      _.each(this.subscriptions, function(subscription) {
        subscription.destroy();
      });
      this.subscriptions = []
    }
  });
})(Monarch);
