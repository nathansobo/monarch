(function(Monarch) {

  Monarch.Repository = new JS.Singleton('Monarch.Repository', {
    initialize: function() {
      this.tables = {}
    },

    buildTable: function(recordClass) {
      var table = new Monarch.Relations.Table(recordClass);
      return this.tables[table.name] = table;
    },

    update: function(hashOrArray) {
      if (_.isArray(hashOrArray)) {
        // commands array
        _.each(hashOrArray, function(command) {
          var operation = this.method('perform' + _.capitalize(command.shift()));
          operation.apply(this, command);
        }, this);
      } else {
        // records hash
        _.each(hashOrArray, function(recordsById, tableName) {
          var table = this.tables[_.singularize(_.camelize(tableName))];
          table.update(recordsById);
        }, this);
      }
    },

    performCreate: function(tableName, attributes) {
      var table = this.getTableByRemoteName(tableName);
      if (table.find(attributes.id)) return;
      table.recordClass.created(_.camelizeKeys(attributes));
    },

    performUpdate: function(tableName, id, attributes) {
      var table = this.getTableByRemoteName(tableName);
      var record = table.find(parseInt(id));
      if (record) record.updated(_.camelizeKeys(attributes));
    },

    performDestroy: function(tableName, id) {
      var table = this.getTableByRemoteName(tableName);
      var record = table.find(parseInt(id));
      if (record) record.destroyed();
    },

    getTableByRemoteName: function(name) {
      return this.tables[_.camelize(_.singularize(name))];
    },

    clear: function() {
      _.each(this.tables, function(table) {
        table.clear();
      });
    }
  });

})(Monarch);