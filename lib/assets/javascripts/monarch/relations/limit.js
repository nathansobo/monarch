//= require monarch/relations/relation

(function(Monarch) {
  Monarch.Relations.Limit = new JS.Class('Monarch.Relations.Limit', Monarch.Relations.Relation, {
    initialize: function(operand, count) {
      this.operand = operand;
      this.count = count;
      this.orderByExpressions = operand.orderByExpressions;
    },

    _all: function() {
      return this.operand.take(this.count);
    },

    _activate: function() {
      this.operand.activate();
      this.callSuper();

      this.subscribe(this.operand, 'onInsert', function(tuple, index, newKey, oldKey) {
        if (index < this.count) {
          var oldLastTuple = this.at(this.count - 1);
          if (oldLastTuple) this.remove(oldLastTuple);
          this.insert(tuple, newKey, oldKey);
        }
      });

      this.subscribe(this.operand, 'onUpdate', function(tuple, changeset, newIndex, oldIndex, newKey, oldKey) {
        if (oldIndex < this.count) {
          if (newIndex < this.count) {
            this.tupleUpdated(tuple, changeset, newKey, oldKey);
          } else {
            this.remove(tuple, newKey, oldKey, changeset);
            var newLastTuple = this.operand.at(this.count - 1);
            if (newLastTuple) this.insert(newLastTuple);
          }
        } else {
          if (newIndex < this.count) {
            var oldLastTuple = this.at(this.count - 1);
            if (oldLastTuple) this.remove(oldLastTuple);
            this.insert(tuple, newKey, oldKey);
          }
        }
      });

      this.subscribe(this.operand, 'onRemove', function(tuple, index, newKey, oldKey) {
        this.remove(tuple, newKey, oldKey);
        var newLastTuple = this.operand.at(this.count - 1);
        if (newLastTuple) this.insert(newLastTuple);
      });
    }
  });

  Monarch.Relations.Limit.deriveEquality('operand', 'count');
  Monarch.Relations.Difference.defineDelegators('operand', 'getColumn', 'inferJoinColumns', 'columns');
})(Monarch);
