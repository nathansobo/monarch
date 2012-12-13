Monarch.Util.Visitor =
  visit: (object) ->
    throw new Error("Cannot visit #{object}") unless object
    constructor = object.constructor
    name = constructor.qualifiedName || constructor.name
    method = @['visit_' + name]
    throw new Error("Cannot visit #{name}") unless method
    method.apply(this, arguments)
