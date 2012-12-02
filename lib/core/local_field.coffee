class Monarch.LocalField extends Monarch.Field
  isDirty: ->
    not _.isEqual(@getValue(), @getRemoteValue())

  getRemoteValue: ->
    @record.getRemoteField(@name).getValue()

  valueChanged: ->
    @record.errors.clear(@name)
