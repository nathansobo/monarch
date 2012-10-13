class Monarch.Expressions.SyntheticColumn extends Monarch.Expressions.Column
  constructor: (@table, @name, @definition) ->

  buildLocalField: (record) ->
    new Monarch.LocalSyntheticField(record, this)

  buildRemoteField: (record) ->
    new Monarch.RemoteSyntheticField(record, this)
