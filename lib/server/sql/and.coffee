module.exports = ({ Monarch, _ }) ->

  class Monarch.Sql.And extends Monarch.Base
    @include Monarch.Sql.Binary
    constructor: (@left, @right) ->
    operator: "AND"
