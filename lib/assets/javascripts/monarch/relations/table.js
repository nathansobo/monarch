(function(Monarch) {
  Monarch.Relations.Table = new JS.Class('Monarch.Relations.Table', Monarch.Relations.Relation, {
    extend: JS.Forwardable,

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
      var parts = name.split('.');
      if (parts.length === 2) {
        if (parts[0] !== this.name) return;
        name = parts[1];
      }
      return this.columnsByName[name];
    },

    columns: function() {
      return _.values(this.columnsByName);
    },

    eachColumn: function(f, ctx) {
      _.each(this.columnsByName, f, ctx);
    },

    defaultOrderBy: function() {
      this.orderByExpressions = this.buildOrderByExpressions(_.toArray(arguments));
      this._contents = this.buildContents();
    },

    buildContents: function() {
      return new Monarch.Util.SkipList(this.buildComparator());
    },

    inferJoinColumns: function(columns) {
      for (var i = 0; i < columns.length; i++) {
        var name = columns[i].name;
        var match = name.match(/^(.+)Id$/);
        if (match && _.camelize(match[1]) === this.name) {
          return [this.getColumn('id'), columns[i]];
        }
      }
    },

    deactivateIfNeeded: function() {
      // no-op
    },

    update: function(recordsById) {
      _.each(recordsById, function(attributes, id) {
        id = parseInt(id);
        var localAttributes = {};
        _.each(attributes, function(value, name) {
          localAttributes[_.camelize(name, true)] = value;
        });

        var existingRecord = this.find(id);
        if (existingRecord) {
          existingRecord.updated(localAttributes);
        } else {
          localAttributes.id = id;
          this.recordClass.created(localAttributes);
        }
      }, this);
    },

    clear: function() {
      this._insertNode.clear();
      this._updateNode.clear();
      this._removeNode.clear();
      this._contents = new Monarch.Util.SkipList(this.buildComparator());
    },

    wireRepresentation: function() {
      return {
        type: 'table',
        name: this.remoteName
      };
    },

    findOrFetch: function(id) {
      var record = this.find(id);
      var promise = new Monarch.Util.Promise;
      if (record) {
        promise.triggerSuccess(record);
        return promise;
      } else {
        Monarch.Remote.Server.fetch(this.where({ id: id })).onSuccess(function() {
          record = this.find(id);
          promise.triggerSuccess(record);
        }, this);
      }
      return promise;
    }
  });

  Monarch.Relations.Table.defineDelegators('recordClass', 'create', 'created');

})(Monarch);
