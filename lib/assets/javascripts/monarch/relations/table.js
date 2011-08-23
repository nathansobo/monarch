(function(Monarch) {
  Monarch.Relations.Table = new JS.Class('Monarch.Relations.Table', {
    initialize: function(recordClass) {
      this.recordClass = recordClass;
      this.name = _.underscoreAndPluralize(recordClass.displayName);
      this.columns = {};
    },

    defineColumn: function(name, type) {
      return this.columns[name] = new Monarch.Expressions.Column(name, type);
    },

    getColumn: function(name) {
      return this.columns[name];
    },

    eachColumn: function(f, ctx) {
      _.each(this.columns, f, ctx);
    }
  });
})(Monarch);