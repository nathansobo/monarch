(function(Monarch) {
  Monarch.Relations.OrderBy = new JS.Class('Monarch.Relations.OrderBy', Monarch.Relations.Relation, {
    initialize: function(operand, orderByStrings) {
      this.operand = operand;
      this.orderByExpressions = this.buildOrderByExpressions(orderByStrings);
    },

    _all: function() {
      return this.operand.all().sort(this.buildComparator(true));
    },

    _activate: function() {
      this.operand.activate();
      this.callSuper();

      this.subscribe(this.operand, 'onInsert', function(tuple) {
        this.insert(tuple);
      });

      this.subscribe(this.operand, 'onUpdate', function(tuple, changeset) {
        this.tupleUpdated(tuple, changeset, this.buildKey(tuple), this.buildKey(tuple, changeset));
      });

      this.subscribe(this.operand, 'onRemove', function(tuple, index, newKey, oldKey, changeset) {
        this.remove(tuple, this.buildKey(tuple), this.buildKey(tuple, changeset));
      });
    },

    buildKey: function(tuple, changeset) {
      var key = this.callSuper(tuple);
      if (changeset) {
        _.each(changeset, function(change) {
          var qName = change.column.qualifiedName;
          if (key[qName]) key[qName] = change.oldValue;
        });
      }
      return key;
    }
  });

  Monarch.Relations.OrderBy.defineDelegators('operand', 'getColumn', 'inferJoinColumns', 'wireRepresentation', 'create', 'created');
})(Monarch);
