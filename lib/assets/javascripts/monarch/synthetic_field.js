(function(Monarch) {
  Monarch.SyntheticField = new JS.Class('Monarch.SyntheticField', {
    initialize: function(record, column) {
      this.record = record;
      this.name = column.name;
      this.signal = column.definition.call(record);
    },

    getValue: function() {
      return this.signal.getValue();
    },

    isDirty: function() {
      return false;
    },

    onChange: function(callback, context) {
      return this.signal.onChange(callback, context);
    }
  });
})(Monarch);
