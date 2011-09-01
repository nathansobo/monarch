//= require monarch/expressions/predicate

(function(Monarch) {
  Monarch.Expressions.LessThanOrEqual = new JS.Class('Monarch.Expressions.LessThanOrEqual', Monarch.Expressions.Predicate, {
    operator: function(left, right) {
      return left <= right;
    }
  });
})(Monarch);
