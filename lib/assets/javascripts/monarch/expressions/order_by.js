(function(Monarch) {
  Monarch.Expressions.OrderBy = new JS.Class('Monarch.Expressions.OrderBy', {
    initialize: function(relation, string) {
      var parts = string.split(/\s+/);
      this.columnName = relation.getColumn(parts[0]).qualifiedName;
      this.directionCoefficient = parts[1] === "desc" ? -1 : 1;
    }
  });
})(Monarch);
