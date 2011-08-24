(function(Monarch) {
  Monarch.Util.Signal = new JS.Class('Monarch.Util.Signal', {
    initialize: function(source, transformer) {
      this.source = source;
      this.transformer = transformer;
      this.changeNode = new Monarch.Util.Node();
      this.source.onChange(function(newValue, oldValue) {
        this.changeNode.publish(this.transformer(newValue), this.transformer(oldValue));
      }, this);
    },

    getValue: function() {
      return this.transformer(this.source.getValue());
    },

    onChange: function(callback, context) {
      return this.changeNode.subscribe(callback, context);
    }
  });
})(Monarch);
