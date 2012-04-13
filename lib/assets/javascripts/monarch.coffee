#= require underscore
#= require_self
#= require_tree ./monarch/util
#= require_tree ./monarch

window.Monarch = (constructor, columnDefinitions) ->
  constructor extends Monarch.Record
  constructor.extended(constructor)
  constructor.columns(columnDefinitions) if columnDefinitions

_.extend Monarch,
  sandboxUrl: '/sandbox'

  Expressions: {}
  Relations: {}
  Remote: {}
  Util: {}

  fetch: (args...) ->
    Monarch.Remote.Server.fetch(args...)
