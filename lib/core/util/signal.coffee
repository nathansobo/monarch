class Monarch.Util.Signal
  constructor: (@sources, @transformer) ->
    @sources = [@sources] unless _.isArray(@sources)
    @transformer ?= (args...) -> args.join(' ')
    @changeNode = new Monarch.Util.Node()
    @subscribeToSource(sourceName, i) for sourceName, i in @sources

  subscribeToSource: (source, index) ->
    source.onChange (newValue, oldValue) =>
      newSourceValues = @getSourceValues()
      oldSourceValues = _.clone(newSourceValues)
      oldSourceValues[index] = oldValue
      @publishChange(newSourceValues, oldSourceValues)

  publishChange: (newSourceValues, oldSourceValues) ->
    newValue = @transformer(newSourceValues...)
    oldValue = @transformer(oldSourceValues...)
    @changeNode.publish(newValue, oldValue)

  getValue: ->
    @transformer(@getSourceValues()...)

  getSourceValues: ->
    _.map @sources, (source) -> source.getValue()

  onChange: (callback, context) ->
    @changeNode.subscribe(callback, context)
