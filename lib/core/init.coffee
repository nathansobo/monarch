window.Monarch = Monarch = (constructor, columnDefinitions) ->
  constructor extends Monarch.Record
  constructor.extended(constructor)
  constructor.columns(columnDefinitions) if columnDefinitions

_.extend Monarch,
  fetchUrl: '/sandbox'
  resourceUrlRoot: ''
  resourceUrlSeparator: '-'
  snakeCase: false

  Expressions: {}
  Relations: {}
  Remote: {}
  Util: {}
