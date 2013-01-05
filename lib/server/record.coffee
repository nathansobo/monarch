module.exports = (Record) ->

  Record.reopen ->
    for methodName in ['deleteAll', 'create']
      do (methodName) =>
        this[methodName] = ->
          @table[methodName].apply(@table, arguments)

    save: ->
      if @isPersisted()
        singletonRelation(this).updateAll(@fieldValues(), arguments...)
      else
        @constructor.table.create(@fieldValues(), arguments...)

    destroy: ->
      if @isPersisted()
        singletonRelation(this).deleteAll(arguments...)

    isPersisted: ->
      @id()?

singletonRelation = (record) ->
  record.constructor.table.where(id: record.id())
