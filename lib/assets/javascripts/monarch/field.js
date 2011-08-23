(function(Monarch) {
  Monarch.Field = new JS.Class('Monarch.Field', {
    initialize: function(record, column) {
      this.record = record;
      this.column = column;
      this.name = this.column.name;
    },

    setValue: function(newValue) {
      var oldValue = this.value;
      this.value = newValue;
      if (!_.isEqual(newValue, oldValue)) this.valueChanged(newValue, oldValue);
      return newValue;
    },

    getValue: function() {
      return this.value;
    }
  })
})(Monarch);
