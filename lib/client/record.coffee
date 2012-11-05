_.extend Monarch.Record.prototype,
  save: ->
    if @id()
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

for methodName in ['fetch', 'findOrFetch']
  do (methodName) =>
    Monarch.Record[methodName] = (args...) ->
      @table[methodName](args...)
