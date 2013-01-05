class Monarch.SyntheticField
  constructor: (@record, @column) ->
    @name = column.name
    @signal = column.definition.call(record)
    @signal.onChange (newValue, oldValue) => @valueChanged(newValue, oldValue)

  getValue: ->
    @signal.getValue()

  isDirty: ->
    false

  onChange: (callback, context) ->
    @signal.onChange(callback, context)

  valueChanged: ->
