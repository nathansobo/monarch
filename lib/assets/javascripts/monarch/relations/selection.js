(function(Monarch) {
  Monarch.Relations.Selection = new JS.Class('Monarch.Relations.Selection', Monarch.Relations.Relation, {
    extend: JS.Forwardable,

    initialize: function(operand, predicate) {
      this.callSuper();
      this.operand = operand;
      this.predicate = this.resolvePredicate(predicate);
      this.orderByExpressions = operand.orderByExpressions;
    },

    all: function() {
      return _.filter(this.operand.all(), function(tuple) {
        return this.predicate.evaluate(tuple);
      }, this);
    },

    _activate: function() {
      this.operand.activate();
      this.callSuper();
      this.subscribe(this.operand, 'onInsert', function(tuple, newKey) {
        if (this.predicate.evaluate(tuple)) this.insert(tuple, newKey);
      });
      this.subscribe(this.operand, 'onUpdate', function(tuple, changeset, _, _, newKey, oldKey) {
        if (this.predicate.evaluate(tuple)) {
          if (this.containsKey(oldKey)) {
            this.tupleUpdated(tuple, changeset, newKey, oldKey);
          } else {
            this.insert(tuple, newKey);
          }
        } else {
          if (this.containsKey(oldKey)) this.remove(tuple, oldKey);
        }
      });
      this.subscribe(this.operand, 'onRemove', function(tuple, _, oldKey) {
        if (this.containsKey(oldKey)) this.remove(tuple, oldKey);
      });
    }
  });

  Monarch.Relations.Selection.deriveEquality('operand', 'predicate');
  Monarch.Relations.Selection.defineDelegators('operand', 'getColumn');
})(Monarch);
