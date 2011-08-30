(function(Monarch) {
  Monarch.Relations.Union = new JS.Class('Monarch.Relations.Union', Monarch.Relations.Relation, {
    initialize: function(left, right) {
      this.left = left;
      this.right = right;
    },

    all: function() {
      return _.union(this.left.all(), this.right.all());
    }
  });

  Monarch.Relations.Union.deriveEquality('left', 'right');
})(Monarch);
