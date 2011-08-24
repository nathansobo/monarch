(function(Monarch) {
  Monarch.Relations.Table = new JS.Class('Monarch.Relations.Table', Monarch.Relations.Relation, {
    initialize: function(recordClass) {
      this.recordClass = recordClass;
      this.name = _.underscoreAndPluralize(recordClass.displayName);
      this.columns = {};
      this.callSuper();
    },

    column: function(name, type) {
      return this.columns[name] = new Monarch.Expressions.Column(name, type);
    },

    syntheticColumn: function(name, definition) {
      return this.columns[name] = new Monarch.Expressions.SyntheticColumn(name, definition);
    },

    getColumn: function(name) {
      return this.columns[name];
    },

    eachColumn: function(f, ctx) {
      _.each(this.columns, f, ctx);
    }
  });
})(Monarch);