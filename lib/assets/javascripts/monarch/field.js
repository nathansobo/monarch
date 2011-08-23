(function(Monarch) {
  Monarch.Field = new JS.Class('Monarch.Field', {
    initialize: function(record, column) {
      this.record = record;
      this.column = column;
    },

    setValue: function(value) {
      return this.value = value;
    },

    getValue: function() {
      return this.value;
    }
  })
})(Monarch);
