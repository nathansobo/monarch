//= require monarch/expressions/predicate

(function(Monarch) {
  Monarch.Expressions.GreaterThan = new JS.Class('Monarch.Expressions.GreaterThan', Monarch.Expressions.Predicate, {
    operator: function(left, right) {
      return left > right;
    }
  });
})(Monarch);
