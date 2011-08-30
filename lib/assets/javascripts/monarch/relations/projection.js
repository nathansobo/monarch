(function(Monarch) {
  Monarch.Relations.Projection = new JS.Class('Monarch.Relations.Projection', Monarch.Relations.Relation, {
    initialize: function(operand, table) {
      this.operand = operand;
      this.table = table.isA(JS.Class) ? table.table : table;
      this.buildOrderByExpressions();
      this.recordCounts = new JS.Hash();
      this.recordCounts.setDefault(0);
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

      this.subscribe(this.operand, 'onInsert', function(tuple, _, newKey, oldKey) {
        this.insert(tuple.getRecord(tableName), newKey, oldKey);
      });

      this.subscribe(this.operand, 'onUpdate', function(tuple, changeset, _, _, newKey, oldKey) {
        this.tupleUpdated(tuple, changeset, newKey, oldKey);
      });

      this.subscribe(this.operand, 'onRemove', function(tuple, _, newKey, oldKey) {
        this.remove(tuple.getRecord(tableName), newKey, oldKey);
      });
    },

    insert: function(record, newKey) {
      var rc = this.recordCounts;
      var count = rc.put(record, rc.get(record) + 1);
      if (count === 1) this.callSuper(record, newKey);
    },

    tupleUpdated: function(tuple, changeset, newKey, oldKey) {
      if (!this.changesetInProjection(changeset)) return;
      if (this.lastUpdate === changeset) return;
      this.lastUpdate = changeset;
      this.callSuper(tuple.getRecord(this.table.name), changeset, newKey, oldKey);
    },

    remove: function(record, oldKey) {
      var rc = this.recordCounts;
      var count = rc.put(record, rc.get(record) - 1);
      if (count === 0) {
        rc.remove(record);
        this.callSuper(record, oldKey);
      }
    },

    changesetInProjection: function(changeset) {
      return _.values(changeset)[0].column.table.name === this.table.name;
    }
  });

  Monarch.Relations.Projection.deriveEquality('operand', 'table');
})(Monarch);
