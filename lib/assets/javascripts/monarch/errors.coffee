class Monarch.Errors
  constructor: ->
    @errorsByField = {}

  add: (name, error) ->
    @errorsByField[name] ?= []
    @errorsByField[name].push(error)

  on: (name) ->
    @errorsByField[name] or []

  assign: (@errorsByField) ->

  isEmpty: ->
    _.isEmpty(@errorsByField)

  clear: (name) ->
    delete @errorsByField[name]
