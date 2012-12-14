module.exports = ({ Monarch, _ }) ->

  class Monarch.Sql.Difference extends Monarch.Base
    @include Monarch.Sql.Binary
    @delegate 'source', 'columns', to: 'left'

    operator: 'EXCEPT'
    constructor: (@left, @right) ->
    operandNeedsParens: -> true
