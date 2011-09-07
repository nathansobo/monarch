//= require monarch/expressions/predicate

(function(Monarch) {
  Monarch.Expressions.LessThan = new JS.Class('Monarch.Expressions.LessThan', Monarch.Expressions.Predicate, {
    wireRepresentationType: 'lt',

    operator: function(left, right) {
      return left < right;
    }
  });
})(Monarch);
