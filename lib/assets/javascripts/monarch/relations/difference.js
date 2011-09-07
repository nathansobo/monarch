//= require monarch/relations/relation

(function(Monarch) {
  Monarch.Relations.Difference = new JS.Class('Monarch.Relations.Difference', Monarch.Relations.Relation, {
    initialize: function(left, right) {
      this.left = left;
      this.right = right;
      this.orderByExpressions = left.orderByExpressions;
    },

    _all: function() {
      return _.difference(this.left.all(), this.right.all());
    },

    _activate: function() {
      this.right.activate();
      this.left.activate();
      this.callSuper();

      this.subscribe(this.left, 'onInsert', function(tuple, index, newKey, oldKey) {
        if (!this.right.containsKey(newKey, oldKey)) this.insert(tuple, newKey, oldKey);
      });

      this.subscribe(this.right, 'onRemove', function(tuple, index, newKey, oldKey) {
        if (this.left.containsKey(newKey, oldKey)) this.insert(tuple, newKey, oldKey);
      });

      this.subscribe(this.left, 'onUpdate', function(tuple, changeset, newIndex, oldIndex, newKey, oldKey) {
        if (!this.right.containsKey(newKey, oldKey)) this.tupleUpdated(tuple, changeset, newKey, oldKey);
      });

      this.subscribe(this.left, 'onRemove', function(tuple, index, newKey, oldKey) {
        if (this.containsKey(oldKey)) this.remove(tuple);
      });

      this.subscribe(this.right, 'onInsert', function(tuple, index, newKey, oldKey) {
        if (this.containsKey(newKey, oldKey)) this.remove(tuple);
      });
    },

    wireRepresentation: function() {
      return {
        type: 'difference',
        left_operand: this.left.wireRepresentation(),
        right_operand: this.right.wireRepresentation()
      }
    }
  });

  Monarch.Relations.Difference.deriveEquality('left', 'right');
  Monarch.Relations.Difference.defineDelegators('left', 'getColumn', 'inferJoinColumns', 'columns');
})(Monarch);
