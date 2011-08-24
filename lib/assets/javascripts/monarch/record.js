(function(Monarch) {
  Monarch.Record = new JS.Class('Monarch.Record', {
    extend: {
      inherited: function(subclass) {
        subclass.table = Monarch.Repository.buildTable(subclass);
        subclass.column('id', 'integer');
      },

      column: function(name, type) {
        var column = this.table.column(name, type)
        this[name] = column;

        this.prototype[name] = function() {
          var field = this.getField(name);
          if (arguments.length === 0) {
            return field.getValue();
          } else {
            return field.setValue(arguments[0]);
          }
        };
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
          return this.getField(name).getValue();
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

      contains: function(record) {
        return this.table.contains(record);
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
      return this.localFields[name];
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
      var wireRepresentation = {};
      _.each(this.localFields, function(field, name) {
        if (field.isDirty()) {
          wireRepresentation[_.underscore(name)] = field.getValue();
        }
      });
      return wireRepresentation;
    },

    remotelyCreated: function(attributes) {
      this.remotelyUpdated(attributes);
      this.table.insert(this);
    },

    remotelyUpdated: function(attributes) {
      var changeset = {};

      _.each(attributes, function(value, name) {
        var field = this.getRemoteField(name);
        var oldValue = field.getValue();
        var newValue = field.setValue(value);

        if (!_.isEqual(oldValue, newValue)) {
          changeset[name] = {
            oldValue: oldValue,
            newValue: newValue
          };
        }
      }, this);

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

    signal: function(name, transformer) {
      return this.getField(name).signal(transformer);
    }
  });
})(Monarch);