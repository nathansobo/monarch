(function(Monarch) {
  Monarch.Relations.Selection = new JS.Class('Monarch.Relations.Selection', Monarch.Relations.Relation, {
    extend: JS.Forwardable,

    initialize: function(operand, predicate) {
      this.operand = operand;
      this.predicate = this.resolvePredicate(predicate);
      this.orderByExpressions = operand.orderByExpressions;
    },

    _all: function() {
      return _.filter(this.operand.all(), function(tuple) {
        return this.predicate.evaluate(tuple);
      }, this);
    },

    _activate: function() {
      this.operand.activate();
      this.callSuper();
      this.subscribe(this.operand, 'onInsert', function(tuple, _, newKey, oldKey) {
        if (this.predicate.evaluate(tuple)) this.insert(tuple, newKey, oldKey);
      });
      this.subscribe(this.operand, 'onUpdate', function(tuple, changeset, _, _, newKey, oldKey) {
        if (this.predicate.evaluate(tuple)) {
          if (this.containsKey(oldKey)) {
            this.tupleUpdated(tuple, changeset, newKey, oldKey);
          } else {
            this.insert(tuple, newKey, oldKey);
          }
        } else {
          if (this.containsKey(oldKey)) this.remove(tuple, newKey, oldKey, changeset);
        }
      });
      this.subscribe(this.operand, 'onRemove', function(tuple, _, newKey, oldKey) {
        if (this.containsKey(oldKey)) this.remove(tuple, newKey, oldKey);
      });
    },

    wireRepresentation: function() {
      return {
        type: 'selection',
        predicate: this.predicate.wireRepresentation(),
        operand: this.operand.wireRepresentation()
      };
    }
  });

  Monarch.Relations.Selection.deriveEquality('operand', 'predicate');
  Monarch.Relations.Selection.defineDelegators('operand', 'getColumn', 'inferJoinColumns', 'columns');
})(Monarch);
