(function(Monarch) {
  Monarch.Expressions.Column = new JS.Class('Monarch.Expressions.Column', {
    initialize: function(table, name, type) {
      this.table = table;
      this.name = name;
      this.type = type;
    },

    buildLocalField: function(record) {
      return new Monarch.LocalField(record, this);
    },

    buildRemoteField: function(record) {
      return new Monarch.RemoteField(record, this);
    },
    
    qualifiedName: function() {
      return this.table.name + "." + this.name;
    }
  });
})(Monarch);
