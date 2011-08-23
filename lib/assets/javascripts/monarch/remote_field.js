(function(Monarch) {
  Monarch.RemoteField = new JS.Class('Monarch.RemoteField', Monarch.Field, {
    valueChanged: function(value) {
      this.setLocalValue(value)
    },

    setLocalValue: function(value) {
      this.record.getField(this.name).setValue(value);
    }
  });
})(Monarch);
