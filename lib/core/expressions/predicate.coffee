class Monarch.Expressions.Predicate extends Monarch.Base
  @deriveEquality 'left', 'right'

  @forSymbol: (symbol) ->
    {
      '<': Monarch.Expressions.LessThan
      '<=': Monarch.Expressions.LessThanOrEqual
      '>': Monarch.Expressions.GreaterThan
      '>=': Monarch.Expressions.GreaterThanOrEqual
    }[symbol]

  constructor: (@left, @right) ->

  evaluate: (tuple) ->
    leftValue = @evaluateOperand(@left, tuple)
    rightValue = @evaluateOperand(@right, tuple)
    @operator(leftValue, rightValue)

  evaluateOperand: (operand, tuple) ->
    if operand instanceof Monarch.Expressions.Column
      tuple.getFieldValue(operand.qualifiedName)
    else
      operand

  resolve: (relation) ->
    new @constructor(@resolveOperand(@left, relation), @resolveOperand(@right, relation))

  resolveOperand: (operand, relation) ->
    if _.isString(operand)
      relation.getColumn(operand) or operand
    else
      operand

  and: (otherPredicate) ->
    new Monarch.Expressions.And(this, otherPredicate)

  wireRepresentation: ->
    type: @wireRepresentationType,
    leftOperand: @operandWireRepresentation(@left),
    rightOperand: @operandWireRepresentation(@right)

  operandWireRepresentation: (operand) ->
    if operand and _.isFunction(operand.wireRepresentation)
      operand.wireRepresentation()
    else
      type: 'Scalar',
      value: operand
