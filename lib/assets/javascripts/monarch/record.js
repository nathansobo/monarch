(function(Monarch) {
  Monarch.Record = new JS.Class('Monarch.Record', {
    include: JS.Forwardable,
    extend: {
      inherited: function(subclass) {
        subclass.table = Monarch.Repository.buildTable(subclass);
        subclass.defineColumn('id', 'integer');
      },

      defineColumn: function(name, type) {
        var column = this.table.defineColumn(name, type)
        this[name] = column;

        this.prototype[name] = function() {
          var field = this.getField(name);
          if (arguments.length === 0) {
            return field.getValue();
          } else {
            return field.setValue(arguments[0]);
          }
        }
      },

      defineColumns: function(hash) {
        _.each(hash, function(type, name) {
          this.defineColumn(name, type);
        }, this);
      },

      create: function(attributes) {
        var record = new this();
        record.localUpdate(attributes);
        return Monarch.Remote.Server.create(record);
      }
    },

    initialize: function() {
      this.table = this.constructor.table;
      this.localFields = {};
      this.remoteFields = {};
      this.table.eachColumn(function(column) {
        this.localFields[column.name] = column.buildLocalField(this);
        this.remoteFields[column.name] = column.buildRemoteField(this);
      }, this);
      this.errors = new Monarch.Errors();
    },

    getField: function(name) {
      return this.localFields[name];
    },

    getRemoteField: function(name) {
      return this.remoteFields[name];
    },

    localUpdate: function(attributes) {
      _.each(attributes, function(value, name) {
        if (_.isFunction(this[name])) this[name](value);
      }, this);
    },

    wireRepresentation: function() {
      var wireRepresentation = {};
      _.each(this.localFields, function(field, name) {
        wireRepresentation[name] = field.getValue();
      });
      return wireRepresentation;
    },

    remotelyCreated: function(attributes) {
      this.remotelyUpdated(attributes)
    },

    remotelyUpdated: function(attributes) {
      _.each(attributes, function(value, name) {
        this.getRemoteField(name).setValue(value);
      }, this);
    },

    isValid: function() {
      return this.errors.isEmpty();
    }
  });
})(Monarch);