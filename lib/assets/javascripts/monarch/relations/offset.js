(function(Monarch) {
  Monarch.Relations.Offset = new JS.Class('Monarch.Relations.Offset', Monarch.Relations.Relation, {
    initialize: function(operand, count) {
      this.operand = operand;
      this.count = count;
    },

    _all: function() {
      return this.operand.drop(this.count);
    }

  });

  Monarch.Relations.Offset.deriveEquality('operand', 'count');
})(Monarch);
