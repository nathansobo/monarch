(function(Monarch) {
  Monarch.Record = new JS.Class('Monarch.Record', {
    extend: {
      inherited: function(recordClass) {
        recordClass.table = Monarch.Repository.buildTable(recordClass);
      }
    }
  });
})(Monarch);