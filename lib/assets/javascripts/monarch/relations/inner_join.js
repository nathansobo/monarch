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

    columns: function() {
      return this.left.columns().concat(this.right.columns());
    },

    getColumn: function(name) {
      return this.left.getColumn(name) || this.right.getColumn(name);
    },

    _all: function() {
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

      this.subscribe(this.left, 'onInsert', function(leftTuple, index, newKey, oldKey) {
        this.handleOperandInsert('left', leftTuple, oldKey);
      });

      this.subscribe(this.right, 'onInsert', function(rightTuple, index, newKey, oldKey) {
        this.handleOperandInsert('right', rightTuple, oldKey);
      });

      this.subscribe(this.left, 'onUpdate', function(leftTuple, changeset, newIndex, oldIndex, newKey, oldKey) {
        this.handleOperandUpdate('left', leftTuple, changeset, oldKey);
      });

      this.subscribe(this.right, 'onUpdate', function(rightTuple, changeset, newIndex, oldIndex, newKey, oldKey) {
        this.handleOperandUpdate('right', rightTuple, changeset, oldKey);
      });

      this.subscribe(this.left, 'onRemove', function(leftTuple, index, newKey, oldKey) {
        this.handleOperandRemove('left', leftTuple, oldKey);
      });

      this.subscribe(this.right, 'onRemove', function(rightTuple, index, newKey, oldKey) {
        this.handleOperandRemove('right', rightTuple, oldKey);
      });
    },

    otherOperand: function(side) {
      return side === 'left' ? this.right : this.left;
    },

    handleOperandInsert: function(side, tuple1, oldKey) {
      this.otherOperand(side).each(function(tuple2) {
        var composite = this.buildComposite(tuple1, tuple2, side);
        var newCompositeKey = this.buildKey(composite);
        var oldCompositeKey = this.buildKey(composite, oldKey);
        if (this.predicate.evaluate(composite)) this.insert(composite, newCompositeKey, oldCompositeKey);
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
            this.insert(composite, newCompositeKey, oldCompositeKey);
          }
        } else {
          if (existingComposite) this.remove(existingComposite, newCompositeKey, oldCompositeKey, changeset);
        }
      }, this);
    },

    handleOperandRemove: function(side, tuple1, oldKey) {
      this.otherOperand(side).each(function(tuple2) {
        var newComposite = this.buildComposite(tuple1, tuple2, side);
        var newCompositeKey = this.buildKey(newComposite);
        var oldCompositeKey = this.buildKey(newComposite, oldKey);
        var existingComposite = this.findByKey(oldCompositeKey);
        if (existingComposite) this.remove(existingComposite, newCompositeKey, oldCompositeKey);
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
    },

    wireRepresentation: function() {
      return {
        type: 'inner_join',
        left_operand: this.left.wireRepresentation(),
        right_operand: this.right.wireRepresentation(),
        predicate: this.predicate.wireRepresentation()
      };
    }
  });

  Monarch.Relations.InnerJoin.deriveEquality('left', 'right', 'predicate');

})(Monarch);
