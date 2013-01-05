class Monarch.LocalField extends Monarch.Field
  isDirty: ->
    not _.isEqual(@wireRepresentation(), @record.getRemoteField(@name).wireRepresentation())

  getRemoteValue: ->
    @record.getRemoteField(@name).getValue()

  valueChanged: (newValue, oldValue) ->
    @record.pendingChangeset?[@name] = {
      newValue: newValue,
      oldValue: oldValue,
      column: @column
    }
    @record.errors.clear(@name)
