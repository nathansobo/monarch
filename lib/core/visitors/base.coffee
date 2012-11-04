class Monarch.Visitors.Base
  visit: (object) ->
    nextProto = object
    method = null

    while (not _.isFunction(method))
      unless nextProto
        throw new Error("Dont' know how to visit #{object}")
      constructor = nextProto.constructor
      method = @["visit#{constructor.name}"]
      nextProto = constructor.__super__
    method.call(this, object)
