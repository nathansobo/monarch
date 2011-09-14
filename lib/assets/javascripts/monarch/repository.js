(function(Monarch) {

  Monarch.Repository = new JS.Singleton('Monarch.Repository', {
    initialize: function() {
      this.tables = {}
    },

    buildTable: function(recordClass) {
      var table = new Monarch.Relations.Table(recordClass);
      return this.tables[table.name] = table;
    },

    update: function(recordsByTable) {
      _.each(recordsByTable, function(recordsById, tableName) {
        var table = this.tables[_.singularize(_.camelize(tableName))];
        table.update(recordsById);
      }, this);
    },

    clear: function() {
      _.each(this.tables, function(table) {
        table.clear();
      });
    }
  });

})(Monarch);