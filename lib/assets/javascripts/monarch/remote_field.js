(function(Monarch) {
  Monarch.RemoteField = new JS.Class('Monarch.RemoteField', Monarch.Field, {
    setValue: function(value) {
      this.callSuper(value);
      this.sisterField().setValue(value);
    },

    sisterField: function() {
      return this.record.getField(this.column.name);
    }
  });
})(Monarch);
