//= require monarch/relations/relation

(function(Monarch) {
  Monarch.Relations.InnerJoin = new JS.Class('Monarch.Relations.InnerJoin', Monarch.Relations.Relation, {
    initialize: function(left, right, predicate) {
      this.left = left.isA(JS.Class) ? left.table : left;
      this.right = right.isA(JS.Class) ? right.table : right;
      this.predicate = this.resolvePredicate(predicate || this.inferPredicate());
    },

    inferPredicate: function() {
      var columns = this.left.inferJoinColumns(this.right.columns()) || this.right.inferJoinColumns(this.left.columns());
      if (!columns) throw new Error("No join predicate could be inferred");
      return columns[0].eq(columns[1]);
    },

    getColumn: function(name) {
      return this.left.getColumn(name) || this.right.getColumn(name);
    },

    all: function() {
      var all = [];
      this.left.each(function(leftTuple) {
        this.right.each(function(rightTuple) {
          var composite = new Monarch.CompositeTuple(leftTuple, rightTuple);
          if (this.predicate.evaluate(composite)) all.push(composite);
        }, this);
      }, this);
      return all;
    }
  });

  Monarch.Relations.InnerJoin.deriveEquality('left', 'right', 'predicate');

})(Monarch);
