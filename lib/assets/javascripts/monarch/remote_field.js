(function(Monarch) {
  Monarch.RemoteField = new JS.Class('Monarch.RemoteField', Monarch.Field, {
    valueChanged: function(newValue, oldValue) {
      this.record.pendingChangeset[this.name] = {
        newValue: newValue,
        oldValue: oldValue
      };
      this.setLocalValue(newValue, oldValue)
    },

    setLocalValue: function(value) {
      this.record.getField(this.name).setValue(value);
    }
  });
})(Monarch);
