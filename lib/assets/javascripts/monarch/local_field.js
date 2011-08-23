(function(Monarch) {
  Monarch.LocalField = new JS.Class('Monarch.LocalField', Monarch.Field, {
    isDirty: function() {
      return !_.isEqual(this.getValue(), this.getRemoteValue());
    },

    getRemoteValue: function() {
      return this.record.getRemoteField(this.column.name).getValue();
    }
  });
})(Monarch);
