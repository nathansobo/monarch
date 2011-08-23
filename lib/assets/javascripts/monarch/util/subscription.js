(function(Monarch) {
  Monarch.Util.Subscription = new JS.Class('Monarch.Util.Subscription', {
    initialize: function(callback, context) {
      this._callback = callback;
      this._context = context;
    },

    publish: function(args) {
      this._callback.apply(this._context, args);
    }
  })
})(Monarch);
