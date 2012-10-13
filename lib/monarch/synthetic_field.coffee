class Monarch.SyntheticField
  constructor: (@record, @column) ->
    @name = column.name
    @signal = column.definition.call(record)

  getValue: ->
    @signal.getValue()

  isDirty: ->
    false

  onChange: (callback, context) ->
    @signal.onChange(callback, context)
