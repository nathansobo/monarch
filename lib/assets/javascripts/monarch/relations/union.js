(function(Monarch) {
  Monarch.Relations.Union = new JS.Class('Monarch.Relations.Union', Monarch.Relations.Relation, {
    initialize: function(left, right) {
      this.left = left;
      this.right = right;
      this.orderByExpressions = this.left.orderByExpressions;
    },

    _all: function() {
      return _.union(this.left.all(), this.right.all()).sort(this.buildComparator(true));
    },

    _activate: function() {
      this.left.activate();
      this.right.activate();
      this.callSuper();
      this.subscribe(this.left, 'onInsert', function(tuple, index, newKey, oldKey) {
        this.handleOperandInsert(tuple, newKey, oldKey);
      });

      this.subscribe(this.right, 'onInsert', function(tuple, index, newKey, oldKey) {
        this.handleOperandInsert(tuple, newKey, oldKey);
      });

      this.subscribe(this.left, 'onUpdate', function(tuple, changeset, newIndex, oldIndex, newKey, oldKey) {
        this.tupleUpdated(tuple, changeset, newKey, oldKey);
      });

      this.subscribe(this.right, 'onUpdate', function(tuple, changeset, newIndex, oldIndex, newKey, oldKey) {
        this.tupleUpdated(tuple, changeset, newKey, oldKey);
      });

      this.subscribe(this.left, 'onRemove', function(tuple, index, newKey, oldKey) {
        this.handleOperandRemove('left', tuple, newKey, oldKey);
      });

      this.subscribe(this.right, 'onRemove', function(tuple, index, newKey, oldKey) {
        this.handleOperandRemove('right', tuple, newKey, oldKey);
      });
    },

    handleOperandInsert: function(tuple, newKey, oldKey) {
      if (!(this.containsKey(newKey, oldKey))) {
        this.insert(tuple, newKey, oldKey);
      }
    },

    tupleUpdated: function(tuple, changeset, newKey, oldKey) {
      if (this.lastUpdate === changeset) return;
      this.lastUpdate = changeset;
      this.callSuper(tuple, changeset, newKey, oldKey);
    },

    handleOperandRemove: function(side, tuple, newKey, oldKey) {
      var otherOperand = this.otherOperand(side);
      if (!otherOperand.containsKey(newKey, oldKey)) this.remove(tuple, newKey, oldKey);
    },

    otherOperand: function(side) {
      return side === 'left' ? this.right : this.left;
    }
  });

  Monarch.Relations.Union.deriveEquality('left', 'right');
  Monarch.Relations.Difference.defineDelegators('left', 'getColumn', 'inferJoinColumns', 'columns');
})(Monarch);
