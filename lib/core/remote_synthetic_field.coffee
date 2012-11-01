class Monarch.RemoteSyntheticField extends Monarch.SyntheticField
  constructor: (record, column) ->
    record.remoteSignals = true
    super(record, column)
    record.remoteSignals = false
    @signal.onChange (newValue, oldValue) => @valueChanged(newValue, oldValue)

  valueChanged: (newValue, oldValue) ->
    @record.pendingChangeset[@name] = {
      newValue: newValue,
      oldValue: oldValue,
      column: @column
    }
