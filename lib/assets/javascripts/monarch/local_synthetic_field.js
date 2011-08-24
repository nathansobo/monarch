//= require monarch/synthetic_field

(function(Monarch) {
  Monarch.LocalSyntheticField = new JS.Class('Monarch.LocalSyntheticField', Monarch.SyntheticField, {
    initialize: function(record, column) {
      this.signal = column.definition.call(record);
    }
  });
})(Monarch);
