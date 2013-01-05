class Monarch.LocalSyntheticField extends Monarch.SyntheticField
  valueChanged: (newValue, oldValue) ->
    @record.pendingChangeset?[@name] = {
      newValue: newValue,
      oldValue: oldValue,
      column: @column
    }
