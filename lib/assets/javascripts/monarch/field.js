(function(Monarch) {
  Monarch.Field = new JS.Class('Monarch.Field', {
    initialize: function(record, column) {
      this.record = record;
      this.column = column;
      this.name = this.column.name;
      this.changeNode = new Monarch.Util.Node();
    },

    setValue: function(newValue) {
      var oldValue = this.value;
      newValue = this.column.normalizeValue(newValue);
      this.value = newValue;
      if (!_.isEqual(newValue, oldValue)) {
        this.valueChanged(newValue, oldValue);
        this.changeNode.publish(newValue, oldValue);
      }
      return newValue;
    },

    getValue: function() {
      return this.value;
    },

    signal: function(transformer) {
      return new Monarch.Util.Signal(this, transformer);
    },

    onChange: function(callback, context) {
      return this.changeNode.subscribe(callback, context)
    }
  })
})(Monarch);
