(function(Monarch) {
  Monarch.Expressions.Column = new JS.Class('Monarch.Expressions.Column', {
    initialize: function(name, type) {
      this.name = name;
      this.type = type;
    },

    buildLocalField: function(record) {
      return new Monarch.LocalField(record, this);
    },

    buildRemoteField: function(record) {
      return new Monarch.RemoteField(record, this);
    }
  });
})(Monarch);
