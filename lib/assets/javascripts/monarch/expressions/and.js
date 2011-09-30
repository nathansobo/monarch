//= require monarch/expressions/predicate

(function(Monarch) {
  Monarch.Expressions.And = new JS.Class('Monarch.Expressions.And', Monarch.Expressions.Predicate, {
    wireRepresentationType: 'and',

    evaluate: function(tuple) {
      return this.left.evaluate(tuple) && this.right.evaluate(tuple);
    },

    satisfyingAttributes: function() {
      return _.extend(this.left.satisfyingAttributes(), this.right.satisfyingAttributes());
    },
    
    resolve: function(relation) {
      return new this.klass(relation.resolvePredicate(this.left), relation.resolvePredicate(this.right));
    }
  });
})(Monarch);
