//= require monarch/relations/relation

(function(Monarch) {
  Monarch.Relations.InnerJoin = new JS.Class('Monarch.Relations.InnerJoin', Monarch.Relations.Relation, {
    initialize: function(left, right, predicate) {
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

    inferJoinColumns: function(columns) {
      return this.left.inferJoinColumns(columns) || this.right.inferJoinColumns(columns);
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
        this.handleOperandInsert('left', leftTuple);
      });

      this.subscribe(this.right, 'onInsert', function(rightTuple) {
        this.handleOperandInsert('right', rightTuple);
      });

      this.subscribe(this.left, 'onUpdate', function(leftTuple, changeset, _, _, newKey, oldKey) {
        this.handleOperandUpdate('left', leftTuple, changeset, oldKey);
      });

      this.subscribe(this.right, 'onUpdate', function(rightTuple, changeset, _, _, newKey, oldKey) {
        this.handleOperandUpdate('right', rightTuple, changeset, oldKey);
      });

      this.subscribe(this.left, 'onRemove', function(leftTuple, _, oldKey) {
        this.handleOperandRemove('left', leftTuple, oldKey);
      });

      this.subscribe(this.right, 'onRemove', function(rightTuple, _, oldKey) {
        this.handleOperandRemove('right', rightTuple, oldKey);
      });
    },

    otherOperand: function(side) {
      return side === 'left' ? this.right : this.left;
    },

    handleOperandInsert: function(side, tuple1) {
      this.otherOperand(side).each(function(tuple2) {
        var composite = this.buildComposite(tuple1, tuple2, side);
        if (this.predicate.evaluate(composite)) this.insert(composite);
      }, this);
    },

    handleOperandUpdate: function(side, tuple1, changeset, oldKey) {
      this.otherOperand(side).each(function(tuple2) {
        var composite = this.buildComposite(tuple1, tuple2, side);
        var newCompositeKey = this.buildKey(composite);
        var oldCompositeKey = this.buildKey(composite, oldKey);
        var existingComposite = this.findByKey(oldCompositeKey);

        if (this.predicate.evaluate(composite)) {
          if (existingComposite) {
            this.tupleUpdated(existingComposite, changeset, newCompositeKey, oldCompositeKey);
          } else {
            this.insert(composite, newCompositeKey);
          }
        } else {
          if (existingComposite) this.remove(existingComposite, oldCompositeKey);
        }
      }, this);
    },

    handleOperandRemove: function(side, tuple1, oldKey) {
      this.otherOperand(side).each(function(tuple2) {
        var newComposite = this.buildComposite(tuple1, tuple2, side);
        var oldCompositeKey = this.buildKey(newComposite, oldKey);
        var existingComposite = this.findByKey(oldCompositeKey);
        if (existingComposite) this.remove(existingComposite, oldCompositeKey);
      }, this);
    },

    buildComposite: function(tuple1, tuple2, sideOfTuple1) {
      if (sideOfTuple1 === 'right') {
        return new Monarch.CompositeTuple(tuple2, tuple1);
      } else {
        return new Monarch.CompositeTuple(tuple1, tuple2);
      }
    },

    buildKey: function(tuple, oldKey) {
      var key = this.callSuper(tuple);
      return oldKey ? _.extend(key, oldKey) : key;
    }
  });

  Monarch.Relations.InnerJoin.deriveEquality('left', 'right', 'predicate');

})(Monarch);
