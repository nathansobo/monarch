//= require monarch/expressions/predicate

(function(Monarch) {
  Monarch.Expressions.LessThan = new JS.Class('Monarch.Expressions.LessThan', Monarch.Expressions.Predicate, {
    operator: function(left, right) {
      return left < right;
    }
  });
})(Monarch);
