(function(Monarch) {
  Monarch.Relations.Projection = new JS.Class('Monarch.Relations.Projection', Monarch.Relations.Relation, {
    initialize: function(operand, table) {
      this.operand = operand;
      this.table = table.isA(JS.Class) ? table.table : table;
      this.buildOrderByExpressions();
    },

    all: function() {
      var tableName = this.table.name;
      return this.operand.map(function(composite) {
        return composite.getRecord(tableName);
      }, this);
    },

    buildOrderByExpressions: function() {
      var tableName = this.table.name;
      this.orderByExpressions = _.filter(this.operand.orderByExpressions, function(orderByExpression) {
        return orderByExpression.column.table.name === tableName;
      });
    },

    _activate: function() {
      this.operand.activate();
      this.callSuper();
      var tableName = this.table.name;

      this.subscribe(this.operand, 'onInsert', function(tuple, _, key) {
        if (!this.containsKey(key)) {
          this.insert(tuple.getRecord(tableName), key);
        }
      });

      this.subscribe(this.operand, 'onUpdate', function(tuple, changeset, __, __, newKey, oldKey) {
        if (_.values(changeset)[0].column.table.name !== tableName) return;
        this.tupleUpdated(tuple.getRecord(tableName), changeset, newKey, oldKey);
      });
    }
  });

  Monarch.Relations.Projection.deriveEquality('operand', 'table');
})(Monarch);
