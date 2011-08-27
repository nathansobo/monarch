(function(Monarch) {
  Monarch.Record = new JS.Class('Monarch.Record', {
    extend: {
      inherited: function(subclass) {
        subclass.table = Monarch.Repository.buildTable(subclass);
        subclass.defineColumnAccessor('id');
      },

      column: function(name, type) {
        var column = this.table.column(name, type)
        this.defineColumnAccessor(name);
      },

      columns: function(hash) {
        _.each(hash, function(type, name) {
          this.column(name, type);
        }, this);
      },

      syntheticColumn: function(name, definition) {
        var column = this.table.syntheticColumn(name, definition);
        this[name] = column;
        this.prototype[name] = function() {
          return this.getFieldValue(name);
        };
      },

      create: function(attributes) {
        var record = new this();
        record.localUpdate(attributes);
        return record.save();
      },

      remotelyCreated: function(attributes) {
        var record = new this();
        record.remotelyCreated(attributes);
        return record;
      },

      defineColumnAccessor: function(name) {
        this[name] = this.table.getColumn(name);
        this.prototype[name] = function() {
          var field = this.getField(name);
          if (arguments.length === 0) {
            return field.getValue();
          } else {
            return field.setValue(arguments[0]);
          }
        };
      }
    },

    initialize: function() {
      this.table = this.constructor.table;
      this.errors = new Monarch.Errors();
      this.localFields = {};
      this.remoteFields = {};

      this.table.eachColumn(function(column) {
        this.localFields[column.name] = column.buildLocalField(this);
        this.remoteFields[column.name] = column.buildRemoteField(this);
      }, this);
    },

    getField: function(name) {
      var parts = name.split('.');
      if (parts.length > 1) {
        if (parts[0] === this.table.name) {
          name = parts[1];
        } else {
          return undefined;
        }
      }

      return this.localFields[name];
    },

    getFieldValue: function(name) {
      return this.getField(name).getValue();
    },

    getRemoteField: function(name) {
      return this.remoteFields[name];
    },

    update: function(attributes) {
      this.localUpdate(attributes);
      return this.save();
    },

    localUpdate: function(attributes) {
      _.each(attributes, function(value, name) {
        if (_.isFunction(this[name])) this[name](value);
      }, this);
    },

    wireRepresentation: function() {
      return this.fieldValues(true);
    },

    fieldValues: function(excludeClean) {
      var fieldValues = {};
      _.each(this.localFields, function(field, name) {
        if (!excludeClean || field.isDirty()) {
          fieldValues[_.underscore(name)] = field.getValue();
        }
      });
      return fieldValues;
    },

    remotelyCreated: function(attributes) {
      this.remotelyUpdated(attributes);
      this.table.insert(this);
    },

    remotelyUpdated: function(attributes) {
      var newRecord = !this.id();
      var changeset = this.pendingChangeset = {};
      var oldKey = this.table.buildKey(this);

      _.each(attributes, function(value, name) {
        this.getRemoteField(name).setValue(value);
      }, this);

      var newKey = this.table.buildKey(this);
      delete this.pendingChangeset;

      if (!newRecord) this.table.tupleUpdated(this, changeset, newKey, oldKey);
      return changeset;
    },

    remotelyDestroyed: function() {
      this.table.remove(this);
    },

    isValid: function() {
      return this.errors.isEmpty();
    },

    isDirty: function() {
      return _.any(this.localFields, function(field) {
        return field.isDirty();
      });
    },

    save: function() {
      if (this.id()) {
        return Monarch.Remote.Server.update(this, this.wireRepresentation());
      } else {
        return Monarch.Remote.Server.create(this, this.wireRepresentation());
      }
    },

    destroy: function() {
      return Monarch.Remote.Server.destroy(this);
    },

    signal: function() {
      var args = _.toArray(arguments), transformer;
      if (_.isFunction(_.last(args))) transformer = args.pop();

      var fields = _.map(args, function(name) {
        return this.remoteSignals ? this.getRemoteField(name) : this.getField(name);
      }, this);

      return new Monarch.Util.Signal(fields, transformer);
    },

    toString: function() {
      return "<" + this.klass.displayName + " " + JSON.stringify(this.fieldValues()) + ">";
    }
  });

  Monarch.Record.__meta__.extend(JS.Forwardable);
  Monarch.Record.__meta__.defineDelegators(
    'table', 'contains', 'onUpdate', 'onInsert', 'onRemove', 'defaultOrderBy',
    'at', 'indexOf', 'where', 'join', 'hasSubscriptions'
  );
})(Monarch);