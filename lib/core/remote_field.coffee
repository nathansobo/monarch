class Monarch.RemoteField extends Monarch.Field
  valueChanged: (newValue, oldValue) ->
    @setLocalValue(newValue, oldValue)

  setLocalValue: (value) ->
    @record.getField(@name).setValue(value)
