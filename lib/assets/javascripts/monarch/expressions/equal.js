//= require monarch/expressions/predicate

(function(Monarch) {
  Monarch.Expressions.Equal = new JS.Class('Monarch.Expressions.Equal', Monarch.Expressions.Predicate, {
    wireRepresentationType: 'eq',

    operator: function(left, right) {
      return _.isEqual(left, right);
    },

    satisfyingAttributes: function() {
      var attributes = {};
      attributes[this.left.name] = this.right;
      return attributes;
    },

    isEqual: function(other) {
      if (!other || this.klass !== other.klass) return false;
      if (_.isEqual(this.left, other.left) && _.isEqual(this.right, other.right)) return true;
      if (_.isEqual(this.left, other.right) && _.isEqual(this.right, other.left)) return true;
      return false;
    }
  });
})(Monarch);
