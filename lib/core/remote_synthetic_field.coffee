class Monarch.RemoteSyntheticField extends Monarch.SyntheticField
  constructor: (record, column) ->
    record.remoteSignals = true
    super(record, column)
    record.remoteSignals = false
