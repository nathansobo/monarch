//= require monarch/relations/relation

(function(Monarch) {
  Monarch.Relations.InnerJoin = new JS.Class('Monarch.Relations.InnerJoin', Monarch.Relations.Relation, {
    initialize: function(left, right, predicate) {
      this.callSuper();
      this.left = left.isA(JS.Class) ? left.table : left;
      this.right = right.isA(JS.Class) ? right.table : right;
      this.predicate = this.resolvePredicate(predicate || this.inferPredicate());
      this.orderByExpressions = this.left.orderByExpressions.concat(this.right.orderByExpressions);
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
          var composite = this.buildComposite(leftTuple, rightTuple);
          if (this.predicate.evaluate(composite)) all.push(composite);
        }, this);
      }, this);
      return all;
    },

    _activate: function() {
      this.left.activate();
      this.right.activate();
      this.callSuper();

      this.subscribe(this.left, 'onInsert', function(leftTuple) {
        this.right.each(function(rightTuple) {
          this.possibleInsertion(leftTuple, rightTuple);
        }, this);
      });

      this.subscribe(this.right, 'onInsert', function(rightTuple) {
        this.left.each(function(leftTuple) {
          this.possibleInsertion(leftTuple, rightTuple);
        }, this);
      });
    },

    possibleInsertion: function(leftTuple, rightTuple) {
      var composite = this.buildComposite(leftTuple, rightTuple);
      if (this.predicate.evaluate(composite)) this.insert(composite);
    },

    buildComposite: function(left, right) {
      return new Monarch.CompositeTuple(left, right);
    }
  });

  Monarch.Relations.InnerJoin.deriveEquality('left', 'right', 'predicate');

})(Monarch);
