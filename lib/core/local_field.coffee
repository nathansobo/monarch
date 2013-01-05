class Monarch.LocalField extends Monarch.Field
  isDirty: ->
    not _.isEqual(@wireRepresentation(), @record.getRemoteField(@name).wireRepresentation())

  getRemoteValue: ->
    @record.getRemoteField(@name).getValue()

  valueChanged: ->
    @record.errors.clear(@name)
