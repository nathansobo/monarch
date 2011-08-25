//= require monarch/expressions/predicate

(function(Monarch) {
  Monarch.Expressions.Equal = new JS.Class('Monarch.Expressions.Equal', Monarch.Expressions.Predicate, {
    operator: function(left, right) {
      return _.isEqual(left, right);
    }
  });
})(Monarch);
