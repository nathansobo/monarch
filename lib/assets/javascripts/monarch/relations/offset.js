(function(Monarch) {
  Monarch.Relations.Offset = new JS.Class('Monarch.Relations.Offset', Monarch.Relations.Relation, {
    initialize: function(operand, count) {
      this.operand = operand;
      this.count = count;
      this.orderByExpressions = operand.orderByExpressions;
    },

    _all: function() {
      return this.operand.drop(this.count);
    },

    _activate: function() {
      this.operand.activate();
      this.callSuper();

      this.subscribe(this.operand, 'onInsert', function(tuple, index, newKey, oldKey) {
        if (index < this.count) {
          var newFirstTuple = this.operand.at(this.count);
          if (newFirstTuple) this.insert(newFirstTuple);
        } else {
          this.insert(tuple, newKey, oldKey);
        }
      });

      this.subscribe(this.operand, 'onUpdate', function(tuple, changeset, newIndex, oldIndex, newKey, oldKey) {
        if (oldIndex < this.count) {
          if (newIndex >= this.count) {
            var oldFirstTuple = this.at(0);
            if (oldFirstTuple) this.remove(oldFirstTuple);
            this.insert(tuple, newKey, oldKey);
          }
        } else {
          if (newIndex < this.count) {
            this.remove(tuple, newKey, oldKey, changeset);
            var newFirstTuple = this.operand.at(this.count);
            if (newFirstTuple) this.insert(newFirstTuple);
          } else {
            this.tupleUpdated(tuple, changeset, newKey, oldKey);
          }
        }
      });

      this.subscribe(this.operand, 'onRemove', function(tuple, index, newKey, oldKey) {
        if (index < this.count) {
          var oldFirstTuple = this.at(0);
          if (oldFirstTuple) this.remove(oldFirstTuple);
        } else {
          this.remove(tuple, newKey, oldKey);
        }
      });
    },

    wireRepresentation: function() {
      return {
        type: 'offset',
        operand: this.operand.wireRepresentation(),
        count: this.count
      };
    }
  });

  Monarch.Relations.Offset.deriveEquality('operand', 'count');
  Monarch.Relations.Difference.defineDelegators('operand', 'getColumn', 'inferJoinColumns', 'columns');
})(Monarch);
