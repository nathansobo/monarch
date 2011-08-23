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
      },

      defineColumns: function(hash) {
        _.each(hash, function(type, name) {
          this.defineColumn(name, type);
        }, this);
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
    },

    getField: function(name) {
      return this.localFields[name];
    }
  });
})(Monarch);