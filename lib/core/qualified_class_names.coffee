modules = ["Expressions", "Relations"]

for moduleName in modules
  for klassName, klass of Monarch[moduleName]
    klass.qualifiedName = moduleName + '_' + klassName
