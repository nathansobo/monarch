Monarch.Util.Visitor =
  visit: (object, args...) ->
    throw new Error("Cannot visit #{object}") unless object
    if object.acceptVisitor?
      object.acceptVisitor(this, args...)
    else
      name = object.constructor.name
      method = this['visit_' + name]
      throw new Error("Cannot visit #{name}") unless method
      method.apply(this, arguments)

for moduleName in ["Expressions", "Relations"]
  _.each Monarch[moduleName], (klass, klassName) ->
    methodName = "visit_#{moduleName}_#{klassName}"
    klass.prototype.acceptVisitor = (visitor, args...) ->
      visitor[methodName](this, args...)
