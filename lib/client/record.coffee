Monarch.Record.reopen ->
  for methodName in ['fetch', 'findOrFetch']
    do (methodName) =>
      this[methodName] = ->
        @table[methodName].apply(this, arguments)

  save: ->
    if @isPersisted()
      return if @beforeUpdate() == false
      Monarch.Remote.Server.update(this, @wireRepresentation())
    else
      return if @beforeCreate() == false
      Monarch.Remote.Server.create(this, @wireRepresentation())

  fetch: ->
    @table.where({ id: @id() }).fetch()

  destroy: ->
    return if @beforeDestroy() == false
    Monarch.Remote.Server.destroy(this)

  isPersisted: ->
    @id() > 0