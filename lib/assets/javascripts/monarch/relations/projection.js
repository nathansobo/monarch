(function(Monarch) {
  Monarch.Relations.Projection = new JS.Class('Monarch.Relations.Projection', Monarch.Relations.Relation, {
    initialize: function(operand, table) {
      this.operand = operand;
      this.table = table.isA(JS.Class) ? table.table : table;
    },

    all: function() {
      var tableName = this.table.name;
      return this.operand.map(function(composite) {
        return composite.getRecord(tableName);
      }, this);
    }
  });

  Monarch.Relations.Projection.deriveEquality('operand', 'table');
})(Monarch);
