(function(Monarch) {
  Monarch.Util.Deferrable = new JS.Module('Monarch.Util.Deferrable', {
    initialize: function() {
      this._deferrableNodes = {};
      this._deferrableData = {};
      this._deferrableTriggerred = {};
    },

    onSuccess: function(callback, context) {
      return this.on('success', callback, context);
    },

    onInvalid: function(callback, context) {
      return this.on('invalid', callback, context);
    },

    onError: function(callback, context) {
      return this.on('error', callback, context);
    },

    triggerSuccess: function() {
      this.trigger('success', arguments);
    },

    triggerInvalid: function() {
      this.trigger('invalid', arguments);
    },

    triggerError: function() {
      this.trigger('error', arguments);
    },

    on: function(eventName, callback, context) {
      if (this._deferrableTriggerred[eventName]) {
        callback.apply(context, this._deferrableData[eventName])
      } else {
        var node = this._deferrableNodes[eventName];
        if (!node) node = this._deferrableNodes[eventName] = new Monarch.Util.Node();
        node.subscribe(callback, context);
      }
      return this;
    },

    trigger: function(eventName, data) {
      this._deferrableTriggerred[eventName] = true;
      this._deferrableData[eventName] = data;
      var node = this._deferrableNodes[eventName];
      if (node) node.publishArgs(data);
    }
  });

  Monarch.Util.Deferrable.success = Monarch.Util.Deferrable.onSuccess;
})(Monarch);
