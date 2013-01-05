class Monarch.RemoteField extends Monarch.Field
  valueChanged: (newValue, oldValue) ->
    @record.pendingChangeset[@name] = {
      newValue: newValue,
      oldValue: oldValue,
      column: @column
    }
    @setLocalValue(newValue, oldValue)

  setLocalValue: (value) ->
    @record.getField(@name).setValue(value)
