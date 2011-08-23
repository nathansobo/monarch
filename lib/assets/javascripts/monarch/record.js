(function(Monarch) {
  Monarch.Record = new JS.Class('Monarch.Record', {
    extend: {
      inherited: function(recordClass) {
        recordClass.table = Monarch.Repository.buildTable(recordClass);
      },

      defineColumn: function(name, type) {
        var column = this.table.defineColumn(name, type)
        this[name] = column;
      }
    }
  });
})(Monarch);