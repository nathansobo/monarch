class Monarch.LocalField extends Monarch.Field
  isDirty: ->
    not _.isEqual(@wireRepresentation(), @record.getRemoteField(@name).wireRepresentation())

  getRemoteValue: ->
    @record.getRemoteField(@name).getValue()

  setValue: (value) ->
    @record.accrueUpdates =>
      super(value)
    @awaitResolution() unless @isResolved()

  valueChanged: (newValue, oldValue) ->
    @record.pendingChangeset[@name] = {
      newValue: newValue,
      oldValue: oldValue,
      column: @column
    }
    @record.errors.clear(@name)

    if @column.type == 'key' and newValue > 0 > oldValue
      @record.fieldResolved(@name, oldValue, newValue)

  awaitResolution: ->
    Monarch.Repository.awaitKeyResolution @value, (resolvedKey) =>
      @setValue(resolvedKey)

  isResolved: ->
    @column.type != 'key' or not (@value < 0)
