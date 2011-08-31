(function(Monarch) {
  Monarch.Relations.OrderBy = new JS.Class('Monarch.Relations.OrderBy', Monarch.Relations.Relation, {
    initialize: function(operand, orderByStrings) {
      this.operand = operand;
      this.orderByExpressions = this.buildOrderByExpressions(orderByStrings);
    },

    _all: function() {
      return this.operand.all().sort(this.buildComparator(true));
    }
  });

  Monarch.Relations.OrderBy.defineDelegators('operand', 'getColumn', 'inferJoinColumns');
})(Monarch);
