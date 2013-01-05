Monarch.Util.Visitor =
  visit: (object, args...) ->
    if object?.acceptVisitor?
      object.acceptVisitor(this, args)
    else
      visitPrimitive.apply(this, arguments)

for moduleName in ["Expressions", "Relations"]
  _.each Monarch[moduleName], (klass, klassName) ->
    methodName = "visit_#{moduleName}_#{klassName}"
    klass.prototype.acceptVisitor = (visitor, args) ->
      visitor[methodName](this, args...)

visitPrimitive = (object) ->
  name = visiteeName(object)
  method = this['visit_' + name]
  throw new Error("Cannot visit #{name}") unless method
  method.apply(this, arguments)

visiteeName = (object) ->
  switch object
    when null then "null"
    when undefined then "undefined"
    else object.constructor.name
