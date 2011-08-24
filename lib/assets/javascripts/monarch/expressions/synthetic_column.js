(function(Monarch) {
  Monarch.Expressions.SyntheticColumn = new JS.Class('Monarch.Expressions.SyntheticColumn', {
    initialize: function(name, definition) {
      this.name = name;
      this.definition = definition;
    },

    buildLocalField: function(record) {
      return new Monarch.LocalSyntheticField(record, this);
    },

    buildRemoteField: function(record) {
      return new Monarch.RemoteSyntheticField(record, this);
    }
  });
})(Monarch);
