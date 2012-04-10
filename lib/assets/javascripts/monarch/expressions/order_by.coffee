class Monarch.Expressions.OrderBy
  constructor: (relation, string) ->
    parts = string.split(/\s+/)
    @column = relation.getColumn(parts[0])
    @columnName = @column.qualifiedName
    @directionCoefficient = if parts[1] == "desc" then -1 else 1
