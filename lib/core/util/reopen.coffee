Monarch.Util.reopen = (klass, f) ->
  prototypeProperties = f.call(klass)
  _.extend(klass.prototype, prototypeProperties)
