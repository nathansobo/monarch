(function(Monarch) {
  Monarch.SyntheticField = new JS.Class('Monarch.SyntheticField', {
    getValue: function() {
      return this.signal.getValue();
    }
  });
})(Monarch);
