(function(Monarch) {
  Monarch.Expressions.Predicate = new JS.Class('Monarch.Expressions.Predicate', {
    initialize: function(left, right) {
      this.left = left;
      this.right = right;
    },

    evaluate: function(tuple) {
      var leftValue = this.evaluateOperand(this.left, tuple);
      var rightValue = this.evaluateOperand(this.right, tuple);
      return this.operator(leftValue, rightValue);
    },

    evaluateOperand: function(operand, tuple) {
      if (operand && _.isObject(operand) && operand.isA(Monarch.Expressions.Column)) {
        return tuple.getFieldValue(operand.qualifiedName);
      } else {
        return operand;
      }
    },

    resolve: function(relation) {
      return new this.klass(this.resolveOperand(this.left, relation), this.resolveOperand(this.right, relation));
    },

    resolveOperand: function(operand, relation) {
      if (_.isString(operand)) {
        var column = relation.getColumn(operand);
        return column ? column : operand;
      } else {
        return operand;
      }
    },

    and: function(otherPredicate) {
      return new Monarch.Expressions.And(this, otherPredicate);
    }
  });
})(Monarch);
