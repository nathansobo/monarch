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
    }
  });

  Monarch.Relations.Limit.deriveEquality('operand', 'count');
})(Monarch);
