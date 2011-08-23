(function(Monarch) {

  Monarch.Repository = new JS.Singleton('Monarch.Repository', {
    initialize: function() {
      this.tables = {}
    },

    buildTable: function(recordClass) {
      var table = new Monarch.Relations.Table(recordClass);
      return this.tables[table.name] = table;
    }
  });

})(Monarch);