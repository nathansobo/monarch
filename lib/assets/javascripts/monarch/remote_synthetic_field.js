//= require monarch/synthetic_field

(function(Monarch) {
  Monarch.RemoteSyntheticField = new JS.Class('Monarch.RemoteSyntheticField', Monarch.SyntheticField, {
    initialize: function(record, column) {
      record.remoteSignals = true;
      this.callSuper(record, column);
      record.remoteSignals = false;
      this.signal.onChange(this.method('valueChanged'));
    },

    valueChanged: function(newValue, oldValue) {
      this.record.pendingChangeset[this.name] = {
        newValue: newValue,
        oldValue: oldValue,
        column: this.column
      };
    }
  });
})(Monarch);
