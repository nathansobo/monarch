module.exports = ({ Monarch, _ }) ->

  class Monarch.Sql.Equals extends Monarch.Base
    @include Monarch.Sql.Binary
    constructor: (@left, @right) ->
    operator: "="
