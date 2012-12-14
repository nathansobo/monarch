module.exports = ({ Monarch, _ }) ->

  class Monarch.Sql.Union extends Monarch.Base
    @include Monarch.Sql.Binary
    @delegate 'source', 'columns', to: 'left'

    operator: 'UNION'
    constructor: (@left, @right) ->
    operandNeedsParens: -> true
