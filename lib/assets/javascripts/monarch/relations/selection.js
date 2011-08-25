(function(Monarch) {
  Monarch.Relations.Selection = new JS.Class('Monarch.Relations.Selection', Monarch.Relations.Relation, {
    extend: JS.Forwardable,

    initialize: function(operand, predicate) {
      this.operand = operand;
      this.predicate = this.resolvePredicate(predicate);
    },

    all: function() {
      return _.filter(this.operand.all(), function(tuple) {
        return this.predicate.evaluate(tuple);
      }, this);
    }
  });

  Monarch.Relations.Selection.defineDelegators('operand', 'getColumn');
})(Monarch);
