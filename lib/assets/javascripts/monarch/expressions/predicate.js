(function(Monarch) {
  Monarch.Expressions.Predicate = new JS.Class('Monarch.Expressions.Predicate', {
    extend: {
      forSymbol: function(symbol) {
        return {
          '<': Monarch.Expressions.LessThan,
          '<=': Monarch.Expressions.LessThanOrEqual,
          '>': Monarch.Expressions.GreaterThan,
          '>=': Monarch.Expressions.GreaterThanOrEqual
        }[symbol];
      }
    },

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
      if (operand && _.isObject(operand) && operand instanceof Monarch.Expressions.Column) {
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
    },

    wireRepresentation: function() {
      return {
        type: this.wireRepresentationType,
        left_operand: this.operandWireRepresentation(this.left),
        right_operand: this.operandWireRepresentation(this.right)
      };
    },

    operandWireRepresentation: function(operand) {
      if (operand && _.isFunction(operand.wireRepresentation)) {
        return operand.wireRepresentation();
      } else {
        return {
          type: 'scalar',
          value: operand
        }
      }
    }
  });

  Monarch.Expressions.Predicate.deriveEquality('left', 'right');
})(Monarch);
