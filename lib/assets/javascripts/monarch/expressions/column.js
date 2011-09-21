(function(Monarch) {
  Monarch.Expressions.Column = new JS.Class('Monarch.Expressions.Column', {
    initialize: function(table, name, type) {
      this.table = table;
      this.name = name;
      this.remoteName = _.underscore(name);
      this.qualifiedName = this.table.name + "." + this.name;
      this.type = type;
    },

    buildLocalField: function(record) {
      return new Monarch.LocalField(record, this);
    },

    buildRemoteField: function(record) {
      return new Monarch.RemoteField(record, this);
    },

    eq: function(right) {
      return new Monarch.Expressions.Equal(this, right);
    },

    wireRepresentation: function() {
      return {
        type: 'column',
        table: this.table.remoteName,
        name: this.remoteName
      };
    },

    normalizeValue: function(value) {
      if (this.type === 'datetime' && _.isNumber(value)) {
        return new Date(value);
      } else {
        return value;
      }
    },

    valueWireRepresentation: function(value) {
      if (this.type === 'datetime') {
        return value.getTime();
      } else {
        return value;
      }
    }
  });
})(Monarch);
