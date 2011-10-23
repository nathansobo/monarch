(function(Monarch) {

  Monarch.Repository = new JS.Singleton('Monarch.Repository', {
    initialize: function() {
      this.tables = {};
      this.pauseCount = 0;
    },

    buildTable: function(recordClass) {
      var table = new Monarch.Relations.Table(recordClass);
      return this.tables[table.name] = table;
    },

    update: function(hashOrArray) {
      if (this.pauseCount > 0) {
        this.deferredUpdates.push(hashOrArray);
        return;
      }

      if (_.isArray(hashOrArray)) {
        // commands array
        if (!_.isArray(hashOrArray[0])) hashOrArray = [hashOrArray]; // allow single commands
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

    isPaused: function() {
      return this.pauseCount > 0;
    },

    pauseUpdates: function() {
      if (this.pauseCount === 0) this.deferredUpdates = [];
      this.pauseCount++;
    },

    resumeUpdates: function() {
      this.pauseCount--;
      if (this.pauseCount === 0) {
        _.each(this.deferredUpdates, function(updateArg) {
          this.update(updateArg);
        }, this);
        delete this.deferredUpdates;
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
      this.pauseCount = 0;
      delete this.deferredUpdates;

      _.each(this.tables, function(table) {
        table.clear();
      });
    }
  });

})(Monarch);
