(function(Monarch) {
  Monarch.Record = new JS.Class('Monarch.Record', {
    extend: {
      inherited: function(subclass) {
        subclass.table = Monarch.Repository.buildTable(subclass);
        subclass.defineColumnAccessor('id');
      },

      column: function(name, type) {
        this.table.column(name, type);
        this.defineColumnAccessor(name);
        return this;
      },

      columns: function(hash) {
        _.each(hash, function(type, name) {
          this.column(name, type);
        }, this);
        return this;
      },

      syntheticColumn: function(name, definition) {
        this.table.syntheticColumn(name, definition);
        this.prototype[name] = function() {
          return this.getFieldValue(name);
        };
        return this;
      },

      hasMany: function(name, options) {
        if (!options) options = {};

        var targetClassName = options.className || _.singularize(_.capitalize(name));
        var foreignKey = options.foreignKey || _.uncapitalize(this.table.name) + "Id";

        return this.relatesTo(name, function() {
          var target = Monarch.Repository.tables[targetClassName];
          var conditions = _.extend({}, options.conditions || {});

          if (options.through) {
            target = this[options.through]().joinThrough(target);
          } else {
            conditions[foreignKey] = this.id();
          }

          var relation = target.where(conditions);
          if (options.orderBy) {
            return relation.orderBy(options.orderBy);
          } else {
            return relation;
          }
        });
      },

      relatesTo: function(name, definition) {
        this.define(name, function() {
          if (this._associations[name]) {
            return this._associations[name];
          } else {
            return this._associations[name] = definition.call(this);
          }
        });
        return this;
      },

      belongsTo: function(name, options) {
        if (!options) options = {};

        var targetClassName = options.className || _.capitalize(name);
        var foreignKey = options.foreignKey || name + "Id";

        this.define(name, function() {
          var target = Monarch.Repository.tables[targetClassName];
          return target.find(this[foreignKey]());
        });
        return this;
      },

      defaultOrderBy: function() {
        this.table.defaultOrderBy.apply(this.table, arguments);
        return this;
      },

      create: function(attributes) {
        var record = new this(attributes);
        return record.save();
      },

      created: function(attributes) {
        var record = new this();
        record.created(attributes);
        return record;
      },

      defineColumnAccessor: function(name) {
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

    initialize: function(attributes) {
      this.table = this.constructor.table;
      this.errors = new Monarch.Errors();
      this._associations = {};
      this.localFields = {};
      this.remoteFields = {};

      this.table.eachColumn(function(column) {
        this.localFields[column.name] = column.buildLocalField(this);
        this.remoteFields[column.name] = column.buildRemoteField(this);
      }, this);

      if (attributes) this.localUpdate(attributes);
      this.afterInitialize();
    },

    afterInitialize: _.identity,
    beforeCreate: _.identity,
    afterCreate: _.identity,
    beforeUpdate: _.identity,
    afterUpdate: _.identity,
    beforeDestroy: _.identity,
    afterDestroy: _.identity,

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

    onUpdate: function(callback, context) {
      if (!this.onUpdateNode) this.onUpdateNode = new Monarch.Util.Node();
      return this.onUpdateNode.subscribe(callback, context);
    },

    onDestroy: function(callback, context) {
      if (!this.onDestroyNode) this.onDestroyNode = new Monarch.Util.Node();
      return this.onDestroyNode.subscribe(callback, context);
    },

    wireRepresentation: function(allFields) {
      return this.fieldValues(true, allFields);
    },

    fieldValues: function(wireRepresentation, allFields) {
      var fieldValues = {};
      _.each(this.localFields, function(field, name) {
        if (wireRepresentation) {
          if ((allFields || field.isDirty()) && !field.isA(Monarch.SyntheticField)) {
            fieldValues[_.underscore(name)] = field.wireRepresentation();
          }
        } else {
          fieldValues[name] = field.getValue();
        }
      });
      return fieldValues;
    },

    created: function(attributes) {
      this.updated(attributes);
      this.table.insert(this);
      this.afterCreate();
    },

    updated: function(attributes) {
      var newRecord = !this.id();
      var changeset = this.pendingChangeset = {};
      var oldKey = this.table.buildKey(this);

      _.each(attributes, function(value, name) {
        var field = this.getRemoteField(name);
        if (field) field.setValue(value);
      }, this);

      var newKey = this.table.buildKey(this);
      delete this.pendingChangeset;

      if (!newRecord && !_.isEmpty(changeset)) this.table.tupleUpdated(this, changeset, newKey, oldKey);
      this.afterUpdate();
      if (this.onUpdateNode) this.onUpdateNode.publish(changeset);
      return changeset;
    },

    destroyed: function() {
      this.table.remove(this);
      this.afterDestroy();
      if (this.onDestroyNode) this.onDestroyNode.publish();
    },

    isValid: function() {
      return this.errors.isEmpty();
    },

    isDirty: function() {
      return _.any(this.localFields, function(field) {
        return field.isDirty();
      });
    },

    isEqual: function(other) {
      return (this.constructor === other.constructor) && (this.id() === other.id());
    },

    save: function() {
      if (this.id()) {
        if (this.beforeUpdate() === false) return;
        return Monarch.Remote.Server.update(this, this.wireRepresentation());
      } else {
        if (this.beforeCreate() === false) return;
        return Monarch.Remote.Server.create(this, this.wireRepresentation());
      }
    },

    fetch: function() {
      return this.table.where({ id: this.id() }).fetch();
    },

    destroy: function() {
      if (this.beforeDestroy() === false) return;
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

    getRecord: function(tableName) {
      if (this.table.name === tableName) return this;
    },

    toString: function() {
      return "<" + this.klass.displayName + " " + JSON.stringify(this.fieldValues()) + ">";
    }
  });

  Monarch.Record.__meta__.extend(JS.Forwardable);
  Monarch.Record.__meta__.defineDelegators(
    'table', 'contains', 'onUpdate', 'onInsert', 'onRemove', 'at', 'indexOf', 'where', 'join',
    'union', 'difference', 'limit', 'offset', 'orderBy', 'hasSubscriptions', 'find', 'size',
    'getColumn', 'all', 'first', 'last', 'fetch', 'clear', 'findOrFetch'
  );
})(Monarch);
