//= require monarch/relations/relation

(function(Monarch) {
  Monarch.Relations.Difference = new JS.Class('Monarch.Relations.Difference', Monarch.Relations.Relation, {
    initialize: function(left, right) {
      this.left = left;
      this.right = right;
    },

    _all: function() {
      return _.difference(this.left.all(), this.right.all());
    }
  });

  Monarch.Relations.Difference.deriveEquality('left', 'right');
})(Monarch);
