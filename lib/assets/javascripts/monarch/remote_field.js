(function(Monarch) {
  Monarch.RemoteField = new JS.Class('Monarch.RemoteField', Monarch.Field, {
    setValue: function(value) {
      value = this.callSuper(value);
      this.sisterField().setValue(value);
      return value;
    },

    sisterField: function() {
      return this.record.getField(this.column.name);
    }
  });
})(Monarch);
