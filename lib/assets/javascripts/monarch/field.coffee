class Monarch.Field
  constructor: (@record, @column) ->
    @name = @column.name
    @changeNode = new Monarch.Util.Node()

  setValue: (newValue) ->
    oldValue = @value
    newValue = @column.normalizeValue(newValue)
    @value = newValue
    unless _.isEqual(newValue, oldValue)
      @valueChanged(newValue, oldValue)
      @changeNode.publish(newValue, oldValue)
    newValue

  getValue: ->
    @value

  wireRepresentation: ->
    @column.valueWireRepresentation(@getValue())

  signal: (transformer) ->
    new Monarch.Util.Signal(this, transformer)

  onChange: (callback, context) ->
    @changeNode.subscribe(callback, context)
