(function(Monarch) {
  Monarch.Relations.Union = new JS.Class('Monarch.Relations.Union', Monarch.Relations.Relation, {
    initialize: function(left, right) {
      this.left = left;
      this.right = right;
      this.orderByExpressions = this.left.orderByExpressions;
    },

    all: function() {
      return _.sortBy(_.union(this.left.all(), this.right.all()), this.buildComparator());
    },

    _activate: function() {
      var __ = _;

      this.left.activate();
      this.right.activate();
      this.callSuper();
      this.subscribe(this.left, 'onInsert', function(tuple, _, newKey, oldKey) {
        this.handleOperandInsert(tuple, newKey, oldKey);
      });

      this.subscribe(this.right, 'onInsert', function(tuple, _, newKey, oldKey) {
        this.handleOperandInsert(tuple, newKey, oldKey);
      });

      this.subscribe(this.left, 'onUpdate', function(tuple, changeset, _, _, newKey, oldKey) {
        this.tupleUpdated(tuple, changeset, newKey, oldKey);
      });

      this.subscribe(this.right, 'onUpdate', function(tuple, changeset, _, _, newKey, oldKey) {
        this.tupleUpdated(tuple, changeset, newKey, oldKey);
      });
    },

    tupleUpdated: function(tuple, changeset, newKey, oldKey) {
      if (this.lastUpdate === changeset) return;
      this.lastUpdate = changeset;
      this.callSuper(tuple, changeset, newKey, oldKey);
    },

    handleOperandInsert: function(tuple, newKey, oldKey) {
      if (!(this.containsKey(oldKey) || this.containsKey(newKey))) {
        this.insert(tuple, newKey, oldKey);
      }
    }
  });

  Monarch.Relations.Union.deriveEquality('left', 'right');
})(Monarch);
