(function(Monarch) {
  Monarch.Relations.Table = new JS.Class('Monarch.Relations.Table', Monarch.Relations.Relation, {
    initialize: function(recordClass) {
      this.recordClass = recordClass;
      this.name = recordClass.displayName;
      this.remoteName = _.underscoreAndPluralize(recordClass.displayName);
      this.columnsByName = {};
      this.column('id', 'integer');
      this.defaultOrderBy('id');
      this.activate();
    },

    column: function(name, type) {
      return this.columnsByName[name] = new Monarch.Expressions.Column(this, name, type);
    },

    syntheticColumn: function(name, definition) {
      return this.columnsByName[name] = new Monarch.Expressions.SyntheticColumn(this, name, definition);
    },

    getColumn: function(name) {
      return this.columnsByName[name];
    },

    columns: function() {
      return _.values(this.columnsByName);
    },

    eachColumn: function(f, ctx) {
      _.each(this.columnsByName, f, ctx);
    },

    defaultOrderBy: function() {
      var orderByStrings = _.toArray(arguments).concat(['id']);
      this.orderByExpressions = _.map(orderByStrings, function(orderByString) {
        return new Monarch.Expressions.OrderBy(this, orderByString);
      }, this);
      this._contents = this.buildContents();
    },

    buildContents: function() {
      return new Monarch.Util.SkipList(this.buildComparator());
    },

    inferJoinColumns: function(columns) {
      for (var i = 0; i < columns.length; i++) {
        var name = columns[i].name;
        var match = name.match(/^(.+)Id$/)
        if (match && _.camelize(match[1]) === this.name) {
          return [this.getColumn('id'), columns[i]];
        }
      }
    },

    deactivateIfNeeded: function() {
      // no-op
    }
  });
})(Monarch);