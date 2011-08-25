(function(Monarch) {
  Monarch.Relations.Table = new JS.Class('Monarch.Relations.Table', Monarch.Relations.Relation, {
    initialize: function(recordClass) {
      this.recordClass = recordClass;
      this.name = recordClass.displayName;
      this.remoteName = _.underscoreAndPluralize(recordClass.displayName);
      this.columns = {};
      this.column('id', 'integer');
      this.orderBy('id');
      this.callSuper();
    },

    column: function(name, type) {
      return this.columns[name] = new Monarch.Expressions.Column(this, name, type);
    },

    syntheticColumn: function(name, definition) {
      return this.columns[name] = new Monarch.Expressions.SyntheticColumn(this, name, definition);
    },

    getColumn: function(name) {
      return this.columns[name];
    },

    eachColumn: function(f, ctx) {
      _.each(this.columns, f, ctx);
    },

    orderBy: function() {
      var orderByStrings = _.toArray(arguments).concat(['id']);
      this.orderByExpressions = _.map(orderByStrings, function(orderByString) {
        return new Monarch.Expressions.OrderBy(this, orderByString);
      }, this);
      this.buildContents();
    }
  });
})(Monarch);