//= require monarch/expressions/predicate

(function(Monarch) {
  Monarch.Expressions.GreaterThanOrEqual = new JS.Class('Monarch.Expressions.GreaterThanOrEqual', Monarch.Expressions.Predicate, {
    operator: function(left, right) {
      return left >= right;
    }
  });
})(Monarch);
